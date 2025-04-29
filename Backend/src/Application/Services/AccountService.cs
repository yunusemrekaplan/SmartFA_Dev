using Application.DTOs.Account;
using Application.Interfaces;
using Application.Interfaces.Services;
using Application.Wrappers;
using AutoMapper;
using Core.Entities;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Application.Services;

/// <summary>
/// IAccountService implementasyonu.
/// </summary>
public class AccountService : IAccountService
{
    private readonly IUnitOfWork _unitOfWork; // Unit of Work inject edildi
    private readonly IMapper _mapper;
    private readonly IValidator<CreateAccountDto> _createAccountValidator;
    private readonly IValidator<UpdateAccountDto> _updateAccountValidator;
    private readonly ILogger<AccountService> _logger;

    public AccountService(
        IUnitOfWork unitOfWork, // Değişti
        IMapper mapper,
        IValidator<CreateAccountDto> createAccountValidator,
        IValidator<UpdateAccountDto> updateAccountValidator,
        ILogger<AccountService> logger)
    {
        _unitOfWork = unitOfWork; // Değişti
        _mapper = mapper;
        _createAccountValidator = createAccountValidator;
        _updateAccountValidator = updateAccountValidator;
        _logger = logger;
    }

    // Hesap bakiyesini hesaplayan yardımcı metot (Örnek)
    private async Task<decimal> CalculateAccountBalance(int accountId, decimal initialBalance)
    {
        // Repository'ye UoW üzerinden erişim
        var transactions = await _unitOfWork.Transactions.GetAsync(t => t.AccountId == accountId && !t.IsDeleted);
        decimal transactionSum = transactions.Sum(t => t.Amount);
        return initialBalance + transactionSum;
    }

    public async Task<Result<IReadOnlyList<AccountDto>>> GetUserAccountsAsync(int userId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim
            var accounts = await _unitOfWork.Accounts.GetAccountsByUserIdAsync(userId);
            var accountDtos = new List<AccountDto>();

            foreach (var account in accounts)
            {
                var dto = _mapper.Map<AccountDto>(account);
                dto = dto with { CurrentBalance = await CalculateAccountBalance(account.Id, account.InitialBalance) };
                accountDtos.Add(dto);
            }

            return Result<IReadOnlyList<AccountDto>>.Success(accountDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için hesaplar getirilirken hata oluştu.", userId);
            return Result<IReadOnlyList<AccountDto>>.Failure("Hesaplar getirilirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<AccountDto>> GetAccountByIdAsync(int userId, int accountId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim
            var account = await _unitOfWork.Accounts.GetAccountByIdAndUserIdAsync(userId, accountId);
            if (account == null)
            {
                return Result<AccountDto>.Failure($"Hesap bulunamadı (ID: {accountId}).");
            }

            var accountDto = _mapper.Map<AccountDto>(account);
            accountDto = accountDto with { CurrentBalance = await CalculateAccountBalance(account.Id, account.InitialBalance) };
            return Result<AccountDto>.Success(accountDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için hesap {AccountId} getirilirken hata oluştu.", userId, accountId);
            return Result<AccountDto>.Failure("Hesap getirilirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<AccountDto>> CreateAccountAsync(int userId, CreateAccountDto createAccountDto)
    {
        var validationResult = await _createAccountValidator.ValidateAsync(createAccountDto);
        if (!validationResult.IsValid)
        {
            return Result<AccountDto>.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            var account = _mapper.Map<Account>(createAccountDto);
            account.UserId = userId;

            // Repository'ye UoW üzerinden erişim
            var addedAccount = await _unitOfWork.Accounts.AddAsync(account);

            // Değişiklikleri kaydet
            await _unitOfWork.CompleteAsync(); // SaveChangesAsync çağrısı burada

            var accountDto = _mapper.Map<AccountDto>(addedAccount);
            accountDto = accountDto with { CurrentBalance = addedAccount.InitialBalance };
            return Result<AccountDto>.Success(accountDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için hesap oluşturulurken hata oluştu: {@CreateAccountDto}", userId, createAccountDto);
            return Result<AccountDto>.Failure("Hesap oluşturulurken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> UpdateAccountAsync(int userId, int accountId, UpdateAccountDto updateAccountDto)
    {
        var validationResult = await _updateAccountValidator.ValidateAsync(updateAccountDto);
        if (!validationResult.IsValid)
        {
            return Result.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            // Repository'ye UoW üzerinden erişim (tracking açık olmalı)
            var account = await _unitOfWork.Accounts.GetAsync(
                predicate: a => a.Id == accountId && a.UserId == userId,
                orderBy: null,
                includeString: null,
                disableTracking: false // Tracking açık olmalı
            );

            if (!account.Any())
            {
                return Result.Failure($"Güncellenecek hesap bulunamadı (ID: {accountId}).");
            }

            var existingAccount = account.First();


            _mapper.Map(updateAccountDto, existingAccount);

            // UpdateAsync state'I modified yapar
            await _unitOfWork.Accounts.UpdateAsync(existingAccount);

            // Değişiklikleri kaydet
            await _unitOfWork.CompleteAsync();

            return Result.Success();
        }
        catch (DbUpdateConcurrencyException ex)
        {
            _logger.LogWarning(ex, "Hesap {AccountId} güncellenirken eş zamanlılık sorunu.", accountId);
            return Result.Failure("Hesap güncellenirken bir sorun oluştu. Lütfen tekrar deneyin.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için hesap {AccountId} güncellenirken hata oluştu: {@UpdateAccountDto}", userId,
                accountId, updateAccountDto);
            return Result.Failure("Hesap güncellenirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> DeleteAccountAsync(int userId, int accountId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim
            var account = await _unitOfWork.Accounts.GetAccountByIdAndUserIdAsync(userId, accountId);
            if (account == null)
            {
                return Result.Failure($"Silinecek hesap bulunamadı (ID: {accountId}).");
            }

            // İlişkili işlemler var mı kontrolü
            var transactions = await _unitOfWork.Transactions.GetTransactionsByAccountIdAsync(userId, accountId);
            if (transactions.Any())
            {
                return Result.Failure("Hesapla ilişkili işlemler varken hesap silinemez.");
            }

            // DeleteAsync state'i modified yapar (soft delete)
            await _unitOfWork.Accounts.DeleteAsync(accountId);

            // Değişiklikleri kaydet
            await _unitOfWork.CompleteAsync();

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için hesap {AccountId} silinirken hata oluştu.", userId, accountId);
            return Result.Failure("Hesap silinirken bir sunucu hatası oluştu.");
        }
    }
}