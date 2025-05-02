using Application.DTOs.Budget;
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
/// IBudgetService implementasyonu.
/// </summary>
public class BudgetService : IBudgetService
{
    private readonly IUnitOfWork _unitOfWork; // Değişti
    private readonly IMapper _mapper;
    private readonly IValidator<CreateBudgetDto> _createValidator;
    private readonly IValidator<UpdateBudgetDto> _updateValidator;
    private readonly ILogger<BudgetService> _logger;

    public BudgetService(
        IUnitOfWork unitOfWork, // Değişti
        IMapper mapper,
        IValidator<CreateBudgetDto> createValidator,
        IValidator<UpdateBudgetDto> updateValidator,
        ILogger<BudgetService> logger)
    {
        _unitOfWork = unitOfWork; // Değişti
        _mapper = mapper;
        _createValidator = createValidator;
        _updateValidator = updateValidator;
        _logger = logger;
    }

    // Belirli bir bütçe için harcanan tutarı hesaplayan yardımcı metot
    private async Task<decimal> CalculateSpentAmount(int userId, int categoryId, int month, int year)
    {
        var startDate = new DateTime(year, month, 1);
        var endDate = startDate.AddMonths(1).AddDays(-1);
        // Repository'ye UoW üzerinden erişim
        var transactions = await _unitOfWork.Transactions.GetAsync(
            t => t.UserId == userId &&
                 t.CategoryId == categoryId &&
                 t.TransactionDate.Date >= startDate.Date &&
                 t.TransactionDate.Date <= endDate.Date &&
                 !t.IsDeleted);
        return Math.Abs(transactions.Sum(t => t.Amount));
    }

    public async Task<Result<IReadOnlyList<BudgetDto>>> GetUserBudgetsByPeriodAsync(int userId, int month, int year)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim
            var budgets = await _unitOfWork.Budgets.GetBudgetsByUserIdAndPeriodAsync(userId, month, year);
            var budgetDtos = new List<BudgetDto>();

            foreach (var budget in budgets)
            {
                var spentAmount = await CalculateSpentAmount(userId, budget.CategoryId, month, year);
                var budgetDto = _mapper.Map<BudgetDto>(budget);
                budgetDto = budgetDto with
                {
                    SpentAmount = spentAmount,
                    RemainingAmount = budget.Amount - spentAmount,
                    CategoryName = budget.Category?.Name ?? "Bilinmeyen Kategori",
                    CategoryIcon = budget.Category?.IconName
                };
                budgetDtos.Add(budgetDto);
            }

            return Result<IReadOnlyList<BudgetDto>>.Success(budgetDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için {Month}/{Year} dönemi bütçeleri getirilirken hata oluştu.", userId, month, year);
            return Result<IReadOnlyList<BudgetDto>>.Failure("Bütçeler getirilirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<BudgetDto>> CreateBudgetAsync(int userId, CreateBudgetDto createBudgetDto)
    {
        var validationResult = await _createValidator.ValidateAsync(createBudgetDto);
        if (!validationResult.IsValid)
        {
            return Result<BudgetDto>.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            // Repository'ye UoW üzerinden erişim
            var category = await _unitOfWork.Categories.GetByIdAsync(createBudgetDto.CategoryId);
            if (category == null || (!category.IsPredefined && category.UserId != userId))
            {
                return Result<BudgetDto>.Failure($"Bütçe için belirtilen kategori bulunamadı (ID: {createBudgetDto.CategoryId}).");
            }

            if (category.Type != CategoryType.Expense)
            {
                return Result<BudgetDto>.Failure("Bütçeler sadece Gider kategorileri için oluşturulabilir.");
            }

            // Repository'ye UoW üzerinden erişim
            var existingBudget = await _unitOfWork.Budgets.GetBudgetByUserIdCategoryAndPeriodAsync(userId, createBudgetDto.CategoryId,
                createBudgetDto.Month, createBudgetDto.Year);
            if (existingBudget != null)
            {
                return Result<BudgetDto>.Failure(
                    $"'{category.Name}' kategorisi için {createBudgetDto.Month}/{createBudgetDto.Year} dönemine ait bir bütçe zaten mevcut.");
            }


            var budget = _mapper.Map<Budget>(createBudgetDto);
            budget.UserId = userId;

            // Repository'ye UoW üzerinden erişim
            var addedBudget = await _unitOfWork.Budgets.AddAsync(budget);
            await _unitOfWork.CompleteAsync(); // Değişiklikleri kaydet

            var budgetDto = _mapper.Map<BudgetDto>(addedBudget);
            budgetDto = budgetDto with
            {
                SpentAmount = 0,
                RemainingAmount = addedBudget.Amount,
                CategoryName = category.Name,
                CategoryIcon = category.IconName
            };
            return Result<BudgetDto>.Success(budgetDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için bütçe oluşturulurken hata oluştu: {@CreateBudgetDto}", userId, createBudgetDto);
            return Result<BudgetDto>.Failure("Bütçe oluşturulurken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> UpdateBudgetAsync(int userId, int budgetId, UpdateBudgetDto updateBudgetDto)
    {
        var validationResult = await _updateValidator.ValidateAsync(updateBudgetDto);
        if (!validationResult.IsValid)
        {
            return Result.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            // Repository'ye UoW üzerinden erişim (tracking açık)
            var budget = await _unitOfWork.Budgets.GetAsync(
                predicate: b => b.Id == budgetId && b.UserId == userId,
                includeString: null,
                disableTracking: false // Tracking açık
            );

            if (!budget.Any())
            {
                return Result.Failure($"Güncellenecek bütçe bulunamadı (ID: {budgetId}).");
            }

            var existingBudget = budget.First();

            _mapper.Map(updateBudgetDto, existingBudget);
            // Repository'ye UoW üzerinden erişim
            await _unitOfWork.Budgets.UpdateAsync(existingBudget);
            await _unitOfWork.CompleteAsync(); // Değişiklikleri kaydet

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için bütçe {BudgetId} güncellenirken hata oluştu: {@UpdateBudgetDto}", userId,
                budgetId, updateBudgetDto);
            return Result.Failure("Bütçe güncellenirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> DeleteBudgetAsync(int userId, int budgetId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim (tracking açık)
            var budget = await _unitOfWork.Budgets.GetAsync(
                predicate: b => b.Id == budgetId && b.UserId == userId,
                includeString: null,
                disableTracking: false
            );

            if (!budget.Any())
            {
                return Result.Failure($"Silinecek bütçe bulunamadı (ID: {budgetId}).");
            }

            // Repository'ye UoW üzerinden erişim
            await _unitOfWork.Budgets.DeleteAsync(budget.First());
            await _unitOfWork.CompleteAsync(); // Değişiklikleri kaydet

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için bütçe {BudgetId} silinirken hata oluştu.", userId, budgetId);
            return Result.Failure("Bütçe silinirken bir sunucu hatası oluştu.");
        }
    }
}