using Application.Interfaces.Repositories;
using Core.Entities;
using Infrastructure.Persistence.Contexts;

namespace Infrastructure.Persistence.Repositories;

/// <summary>
/// IDebtRepository implementasyonu.
/// </summary>
public class DebtRepository : BaseRepository<Debt>, IDebtRepository
{
    public DebtRepository(ApplicationDbContext dbContext) : base(dbContext)
    {
    }

    public async Task<IReadOnlyList<Debt>> GetActiveDebtsByUserIdAsync(int userId)
    {
        // Hem IsDeleted=false hem de IsPaidOff=false olanları getirir.
        // IsDeleted kontrolü BaseRepository'den gelir.
        return await GetAsync(predicate: d => d.UserId == userId && !d.IsPaidOff,
            orderBy: q => q.OrderBy(d => d.Name),
            includeString: null);
    }
}