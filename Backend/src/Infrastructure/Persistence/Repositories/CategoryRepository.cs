using Application.Interfaces.Repositories;
using Core.Entities;
using Core.Enums;
using Infrastructure.Persistence.Contexts;

namespace Infrastructure.Persistence.Repositories;

/// <summary>
/// ICategoryRepository implementasyonu.
/// </summary>
public class CategoryRepository : BaseRepository<Category>, ICategoryRepository
{
    public CategoryRepository(ApplicationDbContext dbContext) : base(dbContext)
    {
    }

    public async Task<IReadOnlyList<Category>> GetCategoriesByUserIdAndTypeAsync(int? userId, CategoryType type)
    {
        // Hem ön tanımlı (UserId == null VE IsPredefined=true) hem de kullanıcıya özel kategorileri getirir.
        // IsDeleted kontrolü BaseRepository'den gelir.
        return await GetAsync(predicate: c => ((c.UserId == userId && !c.IsPredefined) || c.IsPredefined) && c.Type == type,
            orderBy: q => q.OrderBy(c => c.IsPredefined).ThenBy(c => c.Name),
            includeString: null); // Önce ön tanımlılar, sonra ada göre sırala
    }

    public async Task<IReadOnlyList<Category>> GetPredefinedCategoriesByTypeAsync(CategoryType type)
    {
        // Sadece ön tanımlı kategorileri getirir.
        // IsDeleted kontrolü BaseRepository'den gelir.
        return await GetAsync(predicate: c => c.IsPredefined && c.Type == type,
            orderBy: q => q.OrderBy(c => c.Name),
            includeString: null);
    }
}