using Application.Interfaces.Repositories;
using Core.Entities;
using Infrastructure.Persistence.Contexts;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence.Repositories;

/// <summary>
/// IAccountRepository implementasyonu.
/// </summary>
public class AccountRepository : BaseRepository<Account>, IAccountRepository
{
    public AccountRepository(ApplicationDbContext dbContext) : base(dbContext)
    {
    }

    public async Task<IReadOnlyList<Account>> GetAccountsByUserIdAsync(int userId)
    {
        // BaseRepository'deki GetAsync metodu kullanılır.
        // IsDeleted kontrolü BaseRepository'den gelir.
        return await GetAsync(predicate: a => a.UserId == userId,
            orderBy: q => q.OrderBy(a => a.Name),
            includeString: null);
    }

    public async Task<Account?> GetAccountByIdAndUserIdAsync(int userId, int accountId)
    {
        // IsDeleted kontrolü BaseRepository'den gelir.
        // Kullanıcı ID kontrolü eklenir.
        return await _dbSet.AsNoTracking()
            .FirstOrDefaultAsync(a => a.Id == accountId && a.UserId == userId && !a.IsDeleted);
    }
}