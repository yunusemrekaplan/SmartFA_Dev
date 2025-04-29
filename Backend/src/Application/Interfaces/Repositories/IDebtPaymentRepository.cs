using Core.Entities;

namespace Application.Interfaces.Repositories;

/// <summary>
/// DebtPayment entity'si için repository arayüzü.
/// </summary>
public interface IDebtPaymentRepository : IRepository<DebtPayment>
{
    /// <summary>
    /// Belirli bir borca ait tüm ödemeleri getirir.
    /// </summary>
    /// <param name="debtId">Borç ID'si</param>
    /// <returns>Ödeme listesi</returns>
    Task<IReadOnlyList<DebtPayment>> GetPaymentsByDebtIdAsync(int debtId);
}