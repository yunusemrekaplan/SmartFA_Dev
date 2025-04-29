using Core.Entities;

namespace Application.Interfaces.Repositories;

/// <summary>
/// Account entity'si için repository arayüzü.
/// </summary>
public interface IAccountRepository : IRepository<Account>
{
    /// <summary>
    /// Belirli bir kullanıcının tüm hesaplarını getirir (IsDeleted=false olanları).
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <returns>Hesap listesi</returns>
    Task<IReadOnlyList<Account>> GetAccountsByUserIdAsync(int userId);

    /// <summary>
    /// Belirli bir kullanıcının belirli bir ID'ye sahip hesabını getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <param name="accountId">Hesap ID'si</param>
    /// <returns>Hesap veya bulunamazsa null</returns>
    Task<Account?> GetAccountByIdAndUserIdAsync(int userId, int accountId);
}