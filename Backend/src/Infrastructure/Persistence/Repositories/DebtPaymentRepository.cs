using Application.Interfaces.Repositories;
using Core.Entities;
using Infrastructure.Persistence.Contexts;

namespace Infrastructure.Persistence.Repositories;

/// <summary>
/// IDebtPaymentRepository implementasyonu.
/// </summary>
public class DebtPaymentRepository : BaseRepository<DebtPayment>, IDebtPaymentRepository
{
    public DebtPaymentRepository(ApplicationDbContext dbContext) : base(dbContext)
    {
    }

    public async Task<IReadOnlyList<DebtPayment>> GetPaymentsByDebtIdAsync(int debtId)
    {
        // IsDeleted kontrolü BaseRepository'den gelir.
        // Ayrıca ilişkili Debt'in de silinmemiş olmasını kontrol etmek iyi olabilir (opsiyonel)
        // .Include(p => p.Debt).Where(p => !p.Debt.IsDeleted) gibi.
        return await GetAsync(predicate: p => p.DebtId == debtId,
            orderBy: q => q.OrderByDescending(p => p.PaymentDate),
            includeString: null);
    }
}