using Application.DTOs.Debt;
using Application.DTOs.DebtPayment;
using Application.Wrappers;

namespace Application.Interfaces.Services;

/// <summary>
/// Borç yönetimi ile ilgili iş mantığı operasyonlarını tanımlar.
/// </summary>
public interface IDebtService
{
    /// <summary>
    /// Belirli bir kullanıcının aktif borçlarını getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <returns>Borç DTO listesi veya hata sonucu</returns>
    Task<Result<IReadOnlyList<DebtDto>>> GetUserActiveDebtsAsync(int userId);

    /// <summary>
    /// Belirli bir kullanıcının belirli bir borcunu ID ile getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="debtId">Borç ID'si</param>
    /// <returns>Borç DTO'su veya hata sonucu</returns>
    Task<Result<DebtDto>> GetDebtByIdAsync(int userId, int debtId);

    /// <summary>
    /// Belirli bir kullanıcı için yeni bir borç oluşturur.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="createDebtDto">Borç oluşturma bilgileri</param>
    /// <returns>Oluşturulan Borç DTO'su veya hata sonucu</returns>
    Task<Result<DebtDto>> CreateDebtAsync(int userId, CreateDebtDto createDebtDto);

    /// <summary>
    /// Belirli bir kullanıcının borcunu günceller.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="debtId">Güncellenecek Borç ID'si</param>
    /// <param name="updateDebtDto">Güncelleme bilgileri</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> UpdateDebtAsync(int userId, int debtId, UpdateDebtDto updateDebtDto);

    /// <summary>
    /// Belirli bir kullanıcının borcunu siler (Soft Delete).
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="debtId">Silinecek Borç ID'si</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> DeleteDebtAsync(int userId, int debtId);

    /// <summary>
    /// Belirli bir borca ödeme kaydeder ve borcun kalan bakiyesini günceller.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si (yetkilendirme için)</param>
    /// <param name="createDebtPaymentDto">Ödeme bilgileri</param>
    /// <returns>Oluşturulan Ödeme DTO'su veya hata sonucu</returns>
    Task<Result<DebtPaymentDto>> AddDebtPaymentAsync(int userId, CreateDebtPaymentDto createDebtPaymentDto);

    /// <summary>
    /// Belirli bir borcun ödeme geçmişini getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="debtId">Borç ID'si</param>
    /// <returns>Ödeme DTO listesi veya hata sonucu</returns>
    Task<Result<IReadOnlyList<DebtPaymentDto>>> GetDebtPaymentsAsync(int userId, int debtId);
}