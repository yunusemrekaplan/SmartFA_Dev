using Application.DTOs.Budget;
using Application.Wrappers;

namespace Application.Interfaces.Services;

/// <summary>
/// Bütçe yönetimi ile ilgili iş mantığı operasyonlarını tanımlar.
/// </summary>
public interface IBudgetService
{
    /// <summary>
    /// Belirli bir kullanıcının belirli bir dönemdeki bütçelerini getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="month">Ay</param>
    /// <param name="year">Yıl</param>
    /// <returns>Bütçe DTO listesi (harcanan/kalan bilgilerini içerir) veya hata sonucu</returns>
    Task<Result<IReadOnlyList<BudgetDto>>> GetUserBudgetsByPeriodAsync(int userId, int month, int year);

    /// <summary>
    /// Belirli bir kullanıcı için yeni bir bütçe oluşturur.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="createBudgetDto">Bütçe oluşturma bilgileri</param>
    /// <returns>Oluşturulan Bütçe DTO'su veya hata sonucu</returns>
    Task<Result<BudgetDto>> CreateBudgetAsync(int userId, CreateBudgetDto createBudgetDto);

    /// <summary>
    /// Belirli bir kullanıcının bütçesini günceller.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="budgetId">Güncellenecek Bütçe ID'si</param>
    /// <param name="updateBudgetDto">Güncelleme bilgileri</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> UpdateBudgetAsync(int userId, int budgetId, UpdateBudgetDto updateBudgetDto);

    /// <summary>
    /// Belirli bir kullanıcının bütçesini siler (Soft Delete).
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="budgetId">Silinecek Bütçe ID'si</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> DeleteBudgetAsync(int userId, int budgetId);
}