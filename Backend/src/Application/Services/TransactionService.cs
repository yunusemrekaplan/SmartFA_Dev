using System.Linq.Expressions;
using Application.DTOs.Transaction;
using Application.Interfaces;
using Application.Interfaces.Services;
using Application.Wrappers;
using AutoMapper;
using Core.Entities;
using Core.Enums;
using FluentValidation;
using Microsoft.Extensions.Logging;

namespace Application.Services;

/// <summary>
/// ITransactionService implementasyonu.
/// </summary>
public class TransactionService : ITransactionService
{
    private readonly IUnitOfWork _unitOfWork; // Değişti
    private readonly IMapper _mapper;
    private readonly IValidator<CreateTransactionDto> _createValidator;
    private readonly IValidator<UpdateTransactionDto> _updateValidator;
    private readonly ILogger<TransactionService> _logger;

    public TransactionService(
        IUnitOfWork unitOfWork, // Değişti
        IMapper mapper,
        IValidator<CreateTransactionDto> createValidator,
        IValidator<UpdateTransactionDto> updateValidator,
        ILogger<TransactionService> logger)
    {
        _unitOfWork = unitOfWork; // Değişti
        _mapper = mapper;
        _createValidator = createValidator;
        _updateValidator = updateValidator;
        _logger = logger;
    }

    public async Task<Result<IReadOnlyList<TransactionDto>>> GetUserTransactionsFilteredAsync(int userId, TransactionFilterDto filterDto)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim
            var transactions = await _unitOfWork.Transactions.GetTransactionsByUserIdFilteredAsync(
                userId, filterDto.AccountId, filterDto.CategoryId, filterDto.StartDate, filterDto.EndDate,
                filterDto.PageNumber, filterDto.PageSize);

            var transactionDtos = _mapper.Map<IReadOnlyList<TransactionDto>>(transactions);

            if (filterDto.Type.HasValue)
            {
                transactionDtos = transactionDtos.Where(dto => dto.CategoryType == filterDto.Type.Value).ToList();
            }

            return Result<IReadOnlyList<TransactionDto>>.Success(transactionDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için işlemler filtrelenirken hata oluştu: {@FilterDto}", userId, filterDto);
            return Result<IReadOnlyList<TransactionDto>>.Failure("İşlemler getirilirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<TransactionDto>> GetTransactionByIdAsync(int userId, int transactionId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim
            var transaction = await _unitOfWork.Transactions.GetAsync(
                predicate: t => t.Id == transactionId && t.UserId == userId,
                includes: new List<Expression<Func<Transaction, object>>> { t => t.Account, t => t.Category },
                disableTracking: true
            );

            if (!transaction.Any())
            {
                return Result<TransactionDto>.Failure($"İşlem bulunamadı (ID: {transactionId}).");
            }

            var transactionDto = _mapper.Map<TransactionDto>(transaction.First());
            return Result<TransactionDto>.Success(transactionDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için işlem {TransactionId} getirilirken hata oluştu.", userId, transactionId);
            return Result<TransactionDto>.Failure("İşlem getirilirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<TransactionDto>> CreateTransactionAsync(int userId, CreateTransactionDto createTransactionDto)
    {
        var validationResult = await _createValidator.ValidateAsync(createTransactionDto);
        if (!validationResult.IsValid)
        {
            return Result<TransactionDto>.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            // Repository'ye UoW üzerinden erişim
            var account = await _unitOfWork.Accounts.GetAccountByIdAndUserIdAsync(userId, createTransactionDto.AccountId);
            if (account == null)
                return Result<TransactionDto>.Failure($"İşlem için belirtilen hesap bulunamadı (ID: {createTransactionDto.AccountId}).");

            var category = await _unitOfWork.Categories.GetByIdAsync(createTransactionDto.CategoryId);
            if (category == null || (!category.IsPredefined && category.UserId != userId))
            {
                return Result<TransactionDto>.Failure(
                    $"İşlem için belirtilen kategori bulunamadı (ID: {createTransactionDto.CategoryId}).");
            }

            var transaction = _mapper.Map<Transaction>(createTransactionDto);
            transaction.UserId = userId;
            if (category.Type == CategoryType.Expense && transaction.Amount > 0) transaction.Amount *= -1;
            else if (category.Type == CategoryType.Income && transaction.Amount < 0) transaction.Amount *= -1;

            // Repository'ye UoW üzerinden erişim
            var addedTransaction = await _unitOfWork.Transactions.AddAsync(transaction);

            // Değişiklikleri kaydet
            await _unitOfWork.CompleteAsync();

            // DTO'ya map et (ilişkili veriler için tekrar çekmeye gerek yok, UoW sonrası ID atanmış olur)
            var transactionDto = _mapper.Map<TransactionDto>(addedTransaction);
            transactionDto = transactionDto with
            {
                AccountName = account.Name, // Zaten elimizde var
                CategoryName = category.Name, // Zaten elimizde var
                CategoryIcon = category.IconName,
                CategoryType = category.Type
            };

            return Result<TransactionDto>.Success(transactionDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için işlem oluşturulurken hata oluştu: {@CreateTransactionDto}", userId,
                createTransactionDto);
            return Result<TransactionDto>.Failure("İşlem oluşturulurken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> UpdateTransactionAsync(int userId, int transactionId, UpdateTransactionDto updateTransactionDto)
    {
        var validationResult = await _updateValidator.ValidateAsync(updateTransactionDto);
        if (!validationResult.IsValid)
        {
            return Result.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            // Repository'ye UoW üzerinden erişim (tracking açık)
            var transaction = await _unitOfWork.Transactions.GetAsync(
                predicate: t => t.Id == transactionId && t.UserId == userId,
                disableTracking: false,
                includeString: null
            );

            if (!transaction.Any())
            {
                return Result.Failure($"Güncellenecek işlem bulunamadı (ID: {transactionId}).");
            }

            var existingTransaction = transaction.First();

            // Repository'ye UoW üzerinden erişim
            var newAccount = await _unitOfWork.Accounts.GetAccountByIdAndUserIdAsync(userId, updateTransactionDto.AccountId);
            if (newAccount == null)
                return Result.Failure($"İşlem için belirtilen yeni hesap bulunamadı (ID: {updateTransactionDto.AccountId}).");

            var newCategory = await _unitOfWork.Categories.GetByIdAsync(updateTransactionDto.CategoryId);
            if (newCategory == null || (!newCategory.IsPredefined && newCategory.UserId != userId))
            {
                return Result.Failure($"İşlem için belirtilen yeni kategori bulunamadı (ID: {updateTransactionDto.CategoryId}).");
            }

            _mapper.Map(updateTransactionDto, existingTransaction);
            if (newCategory.Type == CategoryType.Expense && existingTransaction.Amount > 0) existingTransaction.Amount *= -1;
            else if (newCategory.Type == CategoryType.Income && existingTransaction.Amount < 0) existingTransaction.Amount *= -1;

            // Repository'ye UoW üzerinden erişim
            await _unitOfWork.Transactions.UpdateAsync(existingTransaction);

            // Değişiklikleri kaydet
            await _unitOfWork.CompleteAsync();

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için işlem {TransactionId} güncellenirken hata oluştu: {@UpdateTransactionDto}",
                userId, transactionId, updateTransactionDto);
            return Result.Failure("İşlem güncellenirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> DeleteTransactionAsync(int userId, int transactionId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim (tracking açık)
            var transaction = await _unitOfWork.Transactions.GetAsync(
                predicate: t => t.Id == transactionId && t.UserId == userId,
                disableTracking: false,
                includeString: null
            );

            if (!transaction.Any())
            {
                return Result.Failure($"Silinecek işlem bulunamadı (ID: {transactionId}).");
            }

            // Repository'ye UoW üzerinden erişim
            await _unitOfWork.Transactions.DeleteAsync(transaction.First());

            // Değişiklikleri kaydet
            await _unitOfWork.CompleteAsync();

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için işlem {TransactionId} silinirken hata oluştu.", userId, transactionId);
            return Result.Failure("İşlem silinirken bir sunucu hatası oluştu.");
        }
    }
}