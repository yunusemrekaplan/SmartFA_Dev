using Application.DTOs.Debt;
using Application.DTOs.DebtPayment;
using Application.Interfaces;
using Application.Interfaces.Services;
using Application.Wrappers;
using AutoMapper;
using Core.Entities;
using FluentValidation;
using Microsoft.Extensions.Logging;

namespace Application.Services;

/// <summary>
/// IDebtService implementasyonu.
/// </summary>
public class DebtService : IDebtService
{
    private readonly IUnitOfWork _unitOfWork; // Değişti
    private readonly IMapper _mapper;
    private readonly IValidator<CreateDebtDto> _createDebtValidator;
    private readonly IValidator<UpdateDebtDto> _updateDebtValidator;
    private readonly IValidator<CreateDebtPaymentDto> _createPaymentValidator;
    private readonly ILogger<DebtService> _logger;

    public DebtService(
        IUnitOfWork unitOfWork, // Değişti
        IMapper mapper,
        IValidator<CreateDebtDto> createDebtValidator,
        IValidator<UpdateDebtDto> updateDebtValidator,
        IValidator<CreateDebtPaymentDto> createPaymentValidator,
        ILogger<DebtService> logger)
    {
        _unitOfWork = unitOfWork; // Değişti
        _mapper = mapper;
        _createDebtValidator = createDebtValidator;
        _updateDebtValidator = updateDebtValidator;
        _createPaymentValidator = createPaymentValidator;
        _logger = logger;
    }

    public async Task<Result<IReadOnlyList<DebtDto>>> GetUserActiveDebtsAsync(int userId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim
            var debts = await _unitOfWork.Debts.GetActiveDebtsByUserIdAsync(userId);
            var debtDtos = _mapper.Map<IReadOnlyList<DebtDto>>(debts);
            return Result<IReadOnlyList<DebtDto>>.Success(debtDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için aktif borçlar getirilirken hata oluştu.", userId);
            return Result<IReadOnlyList<DebtDto>>.Failure("Borçlar getirilirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<DebtDto>> GetDebtByIdAsync(int userId, int debtId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim
            var debt = await _unitOfWork.Debts.GetAsync(
                predicate: d => d.Id == debtId && d.UserId == userId,
                disableTracking: true,
                includeString: "DebtPayments" // İlişkili ödemeleri de dahil et
            );

            if (!debt.Any())
            {
                return Result<DebtDto>.Failure($"Borç bulunamadı (ID: {debtId}).");
            }

            var debtDto = _mapper.Map<DebtDto>(debt.First());
            return Result<DebtDto>.Success(debtDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için borç {DebtId} getirilirken hata oluştu.", userId, debtId);
            return Result<DebtDto>.Failure("Borç getirilirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<DebtDto>> CreateDebtAsync(int userId, CreateDebtDto createDebtDto)
    {
        var validationResult = await _createDebtValidator.ValidateAsync(createDebtDto);
        if (!validationResult.IsValid)
        {
            return Result<DebtDto>.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        if (createDebtDto.RemainingAmount > createDebtDto.TotalAmount)
        {
            return Result<DebtDto>.Failure("Kalan bakiye, toplam borç tutarından büyük olamaz.");
        }

        try
        {
            var debt = _mapper.Map<Debt>(createDebtDto);
            debt.UserId = userId;
            debt.IsPaidOff = (debt.RemainingAmount <= 0);

            // Repository'ye UoW üzerinden erişim
            var addedDebt = await _unitOfWork.Debts.AddAsync(debt);
            await _unitOfWork.CompleteAsync(); // Değişiklikleri kaydet

            var debtDto = _mapper.Map<DebtDto>(addedDebt);
            return Result<DebtDto>.Success(debtDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için borç oluşturulurken hata oluştu: {@CreateDebtDto}", userId, createDebtDto);
            return Result<DebtDto>.Failure("Borç oluşturulurken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> UpdateDebtAsync(int userId, int debtId, UpdateDebtDto updateDebtDto)
    {
        var validationResult = await _updateDebtValidator.ValidateAsync(updateDebtDto);
        if (!validationResult.IsValid)
        {
            return Result.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            // Repository'ye UoW üzerinden erişim (tracking açık)
            var debt = await _unitOfWork.Debts.GetAsync(
                predicate: d => d.Id == debtId && d.UserId == userId,
                disableTracking: false,
                includeString: null
            );

            if (!debt.Any())
            {
                return Result.Failure($"Güncellenecek borç bulunamadı (ID: {debtId}).");
            }

            var existingDebt = debt.First();

            _mapper.Map(updateDebtDto, existingDebt);

            // Repository'ye UoW üzerinden erişim
            await _unitOfWork.Debts.UpdateAsync(existingDebt);
            await _unitOfWork.CompleteAsync(); // Değişiklikleri kaydet

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için borç {DebtId} güncellenirken hata oluştu: {@UpdateDebtDto}", userId, debtId,
                updateDebtDto);
            return Result.Failure("Borç güncellenirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> DeleteDebtAsync(int userId, int debtId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim (tracking açık)
            var debt = await _unitOfWork.Debts.GetAsync(
                predicate: d => d.Id == debtId && d.UserId == userId,
                disableTracking: false,
                includeString: null
            );

            if (!debt.Any())
            {
                return Result.Failure($"Silinecek borç bulunamadı (ID: {debtId}).");
            }

            var existingDebt = debt.First();

            // Repository'ye UoW üzerinden erişim
            var payments = await _unitOfWork.DebtPayments.GetPaymentsByDebtIdAsync(debtId);
            if (payments.Any())
            {
                return Result.Failure("Bu borçla ilişkili ödemeler bulunduğu için silinemez.");
            }

            // Repository'ye UoW üzerinden erişim
            await _unitOfWork.Debts.DeleteAsync(existingDebt);
            await _unitOfWork.CompleteAsync(); // Değişiklikleri kaydet

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için borç {DebtId} silinirken hata oluştu.", userId, debtId);
            return Result.Failure("Borç silinirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<DebtPaymentDto>> AddDebtPaymentAsync(int userId, CreateDebtPaymentDto createDebtPaymentDto)
    {
        var validationResult = await _createPaymentValidator.ValidateAsync(createDebtPaymentDto);
        if (!validationResult.IsValid)
        {
            return Result<DebtPaymentDto>.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            // Repository'ye UoW üzerinden erişim (tracking açık)
            var debt = await _unitOfWork.Debts.GetAsync(
                predicate: d => d.Id == createDebtPaymentDto.DebtId && d.UserId == userId && !d.IsDeleted,
                disableTracking: false,
                includeString: null
            );

            if (!debt.Any())
            {
                return Result<DebtPaymentDto>.Failure($"Ödeme yapılacak borç bulunamadı (ID: {createDebtPaymentDto.DebtId}).");
            }

            var existingDebt = debt.First();

            if (existingDebt.IsPaidOff)
            {
                return Result<DebtPaymentDto>.Failure("Bu borç zaten tamamen ödenmiş.");
            }

            if (createDebtPaymentDto.Amount > existingDebt.RemainingAmount)
            {
                return Result<DebtPaymentDto>.Failure(
                    $"Ödeme tutarı ({createDebtPaymentDto.Amount}), kalan borçtan ({existingDebt.RemainingAmount}) fazla olamaz.");
            }

            var payment = _mapper.Map<DebtPayment>(createDebtPaymentDto);

            // Repository'ye UoW üzerinden erişim
            var addedPayment = await _unitOfWork.DebtPayments.AddAsync(payment);

            existingDebt.RemainingAmount -= payment.Amount;
            if (existingDebt.RemainingAmount <= 0)
            {
                existingDebt.RemainingAmount = 0;
                existingDebt.IsPaidOff = true;
            }

            // Repository'ye UoW üzerinden erişim
            await _unitOfWork.Debts.UpdateAsync(existingDebt);

            // Değişiklikleri tek seferde kaydet
            await _unitOfWork.CompleteAsync();

            var paymentDto = _mapper.Map<DebtPaymentDto>(addedPayment);
            return Result<DebtPaymentDto>.Success(paymentDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için borç ödemesi eklenirken hata oluştu: {@CreateDebtPaymentDto}", userId,
                createDebtPaymentDto);
            return Result<DebtPaymentDto>.Failure("Borç ödemesi eklenirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<IReadOnlyList<DebtPaymentDto>>> GetDebtPaymentsAsync(int userId, int debtId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim
            var debt = await _unitOfWork.Debts.GetAsync(d => d.Id == debtId && d.UserId == userId && !d.IsDeleted);
            if (!debt.Any())
            {
                return Result<IReadOnlyList<DebtPaymentDto>>.Failure($"Borç bulunamadı veya size ait değil (ID: {debtId}).");
            }

            // Repository'ye UoW üzerinden erişim
            var payments = await _unitOfWork.DebtPayments.GetPaymentsByDebtIdAsync(debtId);
            var paymentDtos = _mapper.Map<IReadOnlyList<DebtPaymentDto>>(payments);
            return Result<IReadOnlyList<DebtPaymentDto>>.Success(paymentDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için borç {DebtId} ödemeleri getirilirken hata oluştu.", userId, debtId);
            return Result<IReadOnlyList<DebtPaymentDto>>.Failure("Borç ödemeleri getirilirken bir sunucu hatası oluştu.");
        }
    }
}