using Application.DTOs;
using Application.DTOs.Transaction;
using Application.Wrappers;

namespace Application.Interfaces.Services;

/// <summary>
/// İşlem (Gelir/Gider) yönetimi ile ilgili iş mantığı operasyonlarını tanımlar.
/// </summary>
public interface ITransactionService
{
    /// <summary>
    /// Belirli bir kullanıcının işlemlerini filtrelenmiş olarak getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="filterDto">Filtreleme kriterleri DTO'su (accountId, categoryId, startDate vb.)</param>
    /// <returns>İşlem DTO listesi veya hata sonucu</returns>
    Task<Result<IReadOnlyList<TransactionDto>>>
        GetUserTransactionsFilteredAsync(int userId, TransactionFilterDto filterDto); // Özel filtre DTO'su

    /// <summary>
    /// Belirli bir kullanıcının belirli bir işlemini ID ile getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="transactionId">İşlem ID'si</param>
    /// <returns>İşlem DTO'su veya hata sonucu</returns>
    Task<Result<TransactionDto>> GetTransactionByIdAsync(int userId, int transactionId);

    /// <summary>
    /// Belirli bir kullanıcı için yeni bir işlem oluşturur.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="createTransactionDto">İşlem oluşturma bilgileri</param>
    /// <returns>Oluşturulan İşlem DTO'su veya hata sonucu</returns>
    Task<Result<TransactionDto>> CreateTransactionAsync(int userId, CreateTransactionDto createTransactionDto);

    /// <summary>
    /// Belirli bir kullanıcının işlemini günceller.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="transactionId">Güncellenecek İşlem ID'si</param>
    /// <param name="updateTransactionDto">Güncelleme bilgileri</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> UpdateTransactionAsync(int userId, int transactionId, UpdateTransactionDto updateTransactionDto);

    /// <summary>
    /// Belirli bir kullanıcının işlemini siler (Soft Delete).
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="transactionId">Silinecek İşlem ID'si</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> DeleteTransactionAsync(int userId, int transactionId);
}