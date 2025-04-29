using Application.DTOs.Category;
using Application.Wrappers;
using Core.Enums;

namespace Application.Interfaces.Services;

/// <summary>
/// Kategori yönetimi ile ilgili iş mantığı operasyonlarını tanımlar.
/// </summary>
public interface ICategoryService
{
    /// <summary>
    /// Belirli bir kullanıcının ve ön tanımlı kategorileri tipe göre getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="type">Kategori Tipi (Gelir/Gider)</param>
    /// <returns>Kategori DTO listesi veya hata sonucu</returns>
    Task<Result<IReadOnlyList<CategoryDto>>> GetUserAndPredefinedCategoriesAsync(int userId, CategoryType type);

    /// <summary>
    /// Belirli bir kullanıcı için yeni bir özel kategori oluşturur.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="createCategoryDto">Kategori oluşturma bilgileri</param>
    /// <returns>Oluşturulan Kategori DTO'su veya hata sonucu</returns>
    Task<Result<CategoryDto>> CreateCategoryAsync(int userId, CreateCategoryDto createCategoryDto);

    /// <summary>
    /// Belirli bir kullanıcının özel kategorisini günceller.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="categoryId">Güncellenecek Kategori ID'si</param>
    /// <param name="updateCategoryDto">Güncelleme bilgileri</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> UpdateCategoryAsync(int userId, int categoryId, UpdateCategoryDto updateCategoryDto);

    /// <summary>
    /// Belirli bir kullanıcının özel kategorisini siler (Soft Delete).
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="categoryId">Silinecek Kategori ID'si</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> DeleteCategoryAsync(int userId, int categoryId);
}