using System.Linq.Expressions;
using Application.Interfaces.Repositories;
using Core.Entities;
using Infrastructure.Persistence.Contexts;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence.Repositories;

/// <summary>
/// IBudgetRepository implementasyonu.
/// </summary>
public class BudgetRepository : BaseRepository<Budget>, IBudgetRepository
{
    public BudgetRepository(ApplicationDbContext dbContext) : base(dbContext)
    {
    }

    public async Task<IReadOnlyList<Budget>> GetBudgetsByUserIdAndPeriodAsync(int userId, int month, int year)
    {
        // Kategori bilgilerini de getirmek için Include kullanılır.
        // IsDeleted kontrolü BaseRepository'den gelir.
        return await GetAsync(predicate: b => b.UserId == userId && b.Month == month && b.Year == year,
            orderBy: q => q.OrderBy(b => b.Category.Name), // Kategori adına göre sırala
            includes: new List<Expression<Func<Budget, object>>> { b => b.Category });
    }

    public async Task<Budget?> GetBudgetByUserIdCategoryAndPeriodAsync(int userId, int categoryId, int month, int year)
    {
        // IsDeleted kontrolü BaseRepository'den gelir.
        return await _dbSet.AsNoTracking()
            .FirstOrDefaultAsync(b => b.UserId == userId &&
                                      b.CategoryId == categoryId &&
                                      b.Month == month &&
                                      b.Year == year &&
                                      !b.IsDeleted);
    }
}