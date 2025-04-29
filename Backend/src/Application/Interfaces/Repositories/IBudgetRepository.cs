using Core.Entities;

namespace Application.Interfaces.Repositories;

/// <summary>
/// Budget entity'si için repository arayüzü.
/// </summary>
public interface IBudgetRepository : IRepository<Budget>
{
    /// <summary>
    /// Belirli bir kullanıcının belirli bir ay/yıl için tüm bütçelerini getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="month">Ay</param>
    /// <param name="year">Yıl</param>
    /// <returns>Bütçe listesi</returns>
    Task<IReadOnlyList<Budget>> GetBudgetsByUserIdAndPeriodAsync(int userId, int month, int year);

    /// <summary>
    /// Belirli bir kullanıcının belirli bir kategori ve dönem için bütçesini getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="categoryId">Kategori ID'si</param>
    /// <param name="month">Ay</param>
    /// <param name="year">Yıl</param>
    /// <returns>Bütçe veya bulunamazsa null</returns>
    Task<Budget?> GetBudgetByUserIdCategoryAndPeriodAsync(int userId, int categoryId, int month, int year);
}