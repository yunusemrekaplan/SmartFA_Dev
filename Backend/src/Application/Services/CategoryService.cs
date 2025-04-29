using Application.DTOs.Category;
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
/// ICategoryService implementasyonu.
/// </summary>
public class CategoryService : ICategoryService
{
    private readonly IUnitOfWork _unitOfWork; // Değişti
    private readonly IMapper _mapper;
    private readonly IValidator<CreateCategoryDto> _createValidator;
    private readonly IValidator<UpdateCategoryDto> _updateValidator;
    private readonly ILogger<CategoryService> _logger;

    public CategoryService(
        IUnitOfWork unitOfWork, // Değişti
        IMapper mapper,
        IValidator<CreateCategoryDto> createValidator,
        IValidator<UpdateCategoryDto> updateValidator,
        ILogger<CategoryService> logger)
    {
        _unitOfWork = unitOfWork; // Değişti
        _mapper = mapper;
        _createValidator = createValidator;
        _updateValidator = updateValidator;
        _logger = logger;
    }

    public async Task<Result<IReadOnlyList<CategoryDto>>> GetUserAndPredefinedCategoriesAsync(int userId, CategoryType type)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim
            var categories = await _unitOfWork.Categories.GetCategoriesByUserIdAndTypeAsync(userId, type);
            var categoryDtos = _mapper.Map<IReadOnlyList<CategoryDto>>(categories);
            return Result<IReadOnlyList<CategoryDto>>.Success(categoryDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için {CategoryType} kategorileri getirilirken hata oluştu.", userId, type);
            return Result<IReadOnlyList<CategoryDto>>.Failure("Kategoriler getirilirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<CategoryDto>> CreateCategoryAsync(int userId, CreateCategoryDto createCategoryDto)
    {
        var validationResult = await _createValidator.ValidateAsync(createCategoryDto);
        if (!validationResult.IsValid)
        {
            return Result<CategoryDto>.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            // Repository'ye UoW üzerinden erişim
            var existingCategory = await _unitOfWork.Categories.GetAsync(c =>
                c.UserId == userId && c.Name.ToLower() == createCategoryDto.Name.ToLower() && c.Type == createCategoryDto.Type &&
                !c.IsDeleted);
            if (existingCategory.Any())
            {
                return Result<CategoryDto>.Failure(
                    $"'{createCategoryDto.Name}' adında bir {createCategoryDto.Type} kategorisi zaten mevcut.");
            }

            var category = _mapper.Map<Category>(createCategoryDto);
            category.UserId = userId;
            category.IsPredefined = false;

            // Repository'ye UoW üzerinden erişim
            var addedCategory = await _unitOfWork.Categories.AddAsync(category);
            await _unitOfWork.CompleteAsync(); // Değişiklikleri kaydet

            var categoryDto = _mapper.Map<CategoryDto>(addedCategory);
            return Result<CategoryDto>.Success(categoryDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için kategori oluşturulurken hata oluştu: {@CreateCategoryDto}", userId,
                createCategoryDto);
            return Result<CategoryDto>.Failure("Kategori oluşturulurken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> UpdateCategoryAsync(int userId, int categoryId, UpdateCategoryDto updateCategoryDto)
    {
        var validationResult = await _updateValidator.ValidateAsync(updateCategoryDto);
        if (!validationResult.IsValid)
        {
            return Result.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            // Repository'ye UoW üzerinden erişim (tracking açık)
            var category = await _unitOfWork.Categories.GetAsync(
                predicate: c => c.Id == categoryId && c.UserId == userId && !c.IsPredefined,
                disableTracking: false, // Tracking açık
                includeString: null
            );

            if (!category.Any())
            {
                return Result.Failure($"Güncellenecek kategori bulunamadı veya bu kategori size ait değil (ID: {categoryId}).");
            }

            var existingCategory = category.First();

            // Repository'ye UoW üzerinden erişim
            if (existingCategory.Name.ToLower() != updateCategoryDto.Name.ToLower())
            {
                var duplicateCategory = await _unitOfWork.Categories.GetAsync(c =>
                    c.UserId == userId && c.Name.ToLower() == updateCategoryDto.Name.ToLower() && c.Type == existingCategory.Type &&
                    c.Id != categoryId && !c.IsDeleted);
                if (duplicateCategory.Any())
                {
                    return Result.Failure($"'{updateCategoryDto.Name}' adında başka bir {existingCategory.Type} kategorisi zaten mevcut.");
                }
            }

            _mapper.Map(updateCategoryDto, existingCategory);
            // Repository'ye UoW üzerinden erişim
            await _unitOfWork.Categories.UpdateAsync(existingCategory);
            await _unitOfWork.CompleteAsync(); // Değişiklikleri kaydet

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için kategori {CategoryId} güncellenirken hata oluştu: {@UpdateCategoryDto}", userId,
                categoryId, updateCategoryDto);
            return Result.Failure("Kategori güncellenirken bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> DeleteCategoryAsync(int userId, int categoryId)
    {
        try
        {
            // Repository'ye UoW üzerinden erişim (tracking açık)
            var category = await _unitOfWork.Categories.GetAsync(
                predicate: c => c.Id == categoryId && c.UserId == userId && !c.IsPredefined,
                disableTracking: false,
                includeString: null
            );

            if (!category.Any())
            {
                return Result.Failure($"Silinecek kategori bulunamadı veya bu kategori size ait değil (ID: {categoryId}).");
            }

            var existingCategory = category.First();

            // Repository'ye UoW üzerinden erişim
            var transactions = await _unitOfWork.Transactions.GetAsync(t => t.UserId == userId && t.CategoryId == categoryId);
            if (transactions.Any())
            {
                return Result.Failure("Bu kategoriyle ilişkili işlemler bulunduğu için silinemez.");
            }

            var budgets = await _unitOfWork.Budgets.GetAsync(b => b.UserId == userId && b.CategoryId == categoryId);
            if (budgets.Any())
            {
                return Result.Failure("Bu kategoriyle ilişkili bütçeler bulunduğu için silinemez.");
            }

            // Repository'ye UoW üzerinden erişim
            await _unitOfWork.Categories.DeleteAsync(existingCategory);
            await _unitOfWork.CompleteAsync(); // Değişiklikleri kaydet

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı {UserId} için kategori {CategoryId} silinirken hata oluştu.", userId, categoryId);
            return Result.Failure("Kategori silinirken bir sunucu hatası oluştu.");
        }
    }
}