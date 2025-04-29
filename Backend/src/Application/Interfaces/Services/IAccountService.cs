using Application.DTOs.Account;
using Application.Wrappers;

namespace Application.Interfaces.Services;

/// <summary>
/// Hesap yönetimi ile ilgili iş mantığı operasyonlarını tanımlar.
/// </summary>
public interface IAccountService
{
    /// <summary>
    /// Belirli bir kullanıcının tüm hesaplarını getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <returns>Hesap DTO listesi</returns>
    Task<Result<IReadOnlyList<AccountDto>>> GetUserAccountsAsync(int userId); // Result<T> dönüş tipi önerilir

    /// <summary>
    /// Belirli bir kullanıcının belirli bir hesabını ID ile getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="accountId">Hesap ID'si</param>
    /// <returns>Hesap DTO'su veya hata sonucu</returns>
    Task<Result<AccountDto>> GetAccountByIdAsync(int userId, int accountId);

    /// <summary>
    /// Belirli bir kullanıcı için yeni bir hesap oluşturur.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="createAccountDto">Hesap oluşturma bilgileri</param>
    /// <returns>Oluşturulan Hesap DTO'su veya hata sonucu</returns>
    Task<Result<AccountDto>> CreateAccountAsync(int userId, CreateAccountDto createAccountDto);

    /// <summary>
    /// Belirli bir kullanıcının hesabını günceller.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="accountId">Güncellenecek Hesap ID'si</param>
    /// <param name="updateAccountDto">Güncelleme bilgileri</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> UpdateAccountAsync(int userId, int accountId, UpdateAccountDto updateAccountDto); // Başarı/hata için Result

    /// <summary>
    /// Belirli bir kullanıcının hesabını siler (Soft Delete).
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="accountId">Silinecek Hesap ID'si</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> DeleteAccountAsync(int userId, int accountId);
}