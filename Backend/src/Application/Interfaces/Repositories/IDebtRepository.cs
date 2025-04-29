using Core.Entities;

namespace Application.Interfaces.Repositories;

/// <summary>
/// Debt entity'si için repository arayüzü.
/// </summary>
public interface IDebtRepository : IRepository<Debt>
{
    /// <summary>
    /// Belirli bir kullanıcının aktif (IsDeleted=false ve IsPaidOff=false) borçlarını getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si</param>
    /// <returns>Borç listesi</returns>
    Task<IReadOnlyList<Debt>> GetActiveDebtsByUserIdAsync(int userId);
}