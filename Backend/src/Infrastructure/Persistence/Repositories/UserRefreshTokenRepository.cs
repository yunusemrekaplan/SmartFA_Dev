using System.Linq.Expressions;
using Application.Interfaces.Repositories;
using Core.Entities;
using Infrastructure.Persistence.Contexts;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence.Repositories;

/// <summary>
/// IUserRefreshTokenRepository arayüzünün EF Core implementasyonu.
/// </summary>
public class UserRefreshTokenRepository : IUserRefreshTokenRepository
{
    private readonly ApplicationDbContext _dbContext;
    private readonly DbSet<UserRefreshToken> _dbSet;

    public UserRefreshTokenRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _dbSet = _dbContext.Set<UserRefreshToken>();
    }

    public async Task<UserRefreshToken?> GetByTokenAsync(string token)
    {
        // İlişkili User bilgisini de getirmek için Include kullanıyoruz.
        return await _dbSet
            .Include(rt => rt.User)
            .FirstOrDefaultAsync(rt => rt.Token == token);
    }

    public async Task<UserRefreshToken> AddAsync(UserRefreshToken refreshToken)
    {
        await _dbSet.AddAsync(refreshToken);
        // SaveChangesAsync burada çağrılmaz (Unit of Work yönetecek).
        return refreshToken;
    }

    public Task UpdateAsync(UserRefreshToken refreshToken)
    {
        // Entity'nin durumunu Modified olarak işaretle.
        // RevokedAt gibi alanların serviste ayarlandığını varsayıyoruz.
        _dbContext.Entry(refreshToken).State = EntityState.Modified;
        // SaveChangesAsync burada çağrılmaz.
        return Task.CompletedTask;
    }

    public async Task<List<UserRefreshToken>> GetActiveTokensByUserIdAsync(int userId)
    {
        var now = DateTime.UtcNow;
        // IsActive property'sini kullanamayız çünkü veritabanında yok.
        // Doğrudan koşulları yazarız: RevokedAt null VE ExpiresAt > now
        return await _dbSet
            .Where(rt => rt.UserId == userId && rt.RevokedAt == null && rt.ExpiresAt > now)
            .ToListAsync();
    }

    public async Task<List<UserRefreshToken>> GetWhereAsync(Expression<Func<UserRefreshToken, bool>> predicate, bool disableTracking = true)
    {
        IQueryable<UserRefreshToken> query = _dbSet;
        if (disableTracking)
        {
            query = query.AsNoTracking();
        }

        return await query.Where(predicate).ToListAsync();
    }
}