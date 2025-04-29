using Core.Entities;
using Core.Enums;

namespace Application.Interfaces.Repositories;

/// <summary>
/// Category entity'si için repository arayüzü.
/// </summary>
public interface ICategoryRepository : IRepository<Category>
{
    /// <summary>
    /// Belirli bir kullanıcının özel kategorilerini veya ön tanımlı kategorileri getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si (Ön tanımlılar için null olabilir)</param>
    /// <param name="type">Kategori Tipi (Gelir/Gider)</param>
    /// <returns>Kategori listesi</returns>
    Task<IReadOnlyList<Category>> GetCategoriesByUserIdAndTypeAsync(int? userId, CategoryType type);

    /// <summary>
    /// Ön tanımlı kategorileri getirir.
    /// </summary>
    /// <param name="type">Kategori Tipi (Gelir/Gider)</param>
    /// <returns>Kategori listesi</returns>
    Task<IReadOnlyList<Category>> GetPredefinedCategoriesByTypeAsync(CategoryType type);
}