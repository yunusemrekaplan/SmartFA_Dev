using Core.Entities;

namespace Application.Interfaces.Repositories;

/// <summary>
/// Transaction entity'si için repository arayüzü.
/// </summary>
public interface ITransactionRepository : IRepository<Transaction>
{
    /// <summary>
    /// Belirli bir kullanıcının işlemlerini filtreleyerek ve sayfalayarak getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="accountId">Hesap ID'si (opsiyonel filtre)</param>
    /// <param name="categoryId">Kategori ID'si (opsiyonel filtre)</param>
    /// <param name="startDate">Başlangıç tarihi (opsiyonel filtre)</param>
    /// <param name="endDate">Bitiş tarihi (opsiyonel filtre)</param>
    /// <param name="pageNumber">Sayfa numarası</param>
    /// <param name="pageSize">Sayfa boyutu</param>
    /// <returns>Sayfalanmış işlem listesi</returns>
    Task<IReadOnlyList<Transaction>> GetTransactionsByUserIdFilteredAsync(
        int userId, int? accountId, int? categoryId, DateTime? startDate, DateTime? endDate,
        int pageNumber, int pageSize);

    /// <summary>
    /// Belirli bir kullanıcının belirli bir hesaba ait işlemlerini getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="accountId">Hesap ID'si</param>
    /// <returns>İşlem listesi</returns>
    Task<IReadOnlyList<Transaction>> GetTransactionsByAccountIdAsync(int userId, int accountId);

    /// <summary>
    /// Belirli bir kullanıcının belirli bir kategoriye ait işlemlerini getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="categoryId">Kategori ID'si</param>
    /// <returns>İşlem listesi</returns>
    Task<IReadOnlyList<Transaction>> GetTransactionsByCategoryIdAsync(int userId, int categoryId);
}