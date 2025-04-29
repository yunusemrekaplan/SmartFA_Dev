using System.Linq.Expressions;
using Application.Interfaces.Repositories;
using Core.Entities.Core;
using Infrastructure.Persistence.Contexts;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence.Repositories;

/// <summary>
/// IRepository<T> arayüzünün temel EF Core implementasyonu.
/// Soft delete (IsDeleted) mantığını uygular.
/// </summary>
/// <typeparam name="T">BaseEntity'den türeyen entity tipi</typeparam>
public class BaseRepository<T> : IRepository<T> where T : BaseEntity
{
    protected readonly ApplicationDbContext _dbContext; // Veritabanı context'i
    protected readonly DbSet<T> _dbSet; // İlgili entity için DbSet

    public BaseRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _dbSet = _dbContext.Set<T>();
    }

    // --- Read Operations (IsDeleted = false kontrolü ile) ---

    public virtual async Task<T?> GetByIdAsync(int id)
    {
        // AsNoTracking() okuma işlemlerinde performansı artırır.
        // IsDeleted kontrolü ile sadece aktif kayıtları getirir.
        return await _dbSet.AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == id && !e.IsDeleted);
    }

    public virtual async Task<IReadOnlyList<T>> GetAllAsync()
    {
        return await _dbSet.Where(e => !e.IsDeleted)
            .AsNoTracking()
            .ToListAsync();
    }

    public virtual async Task<IReadOnlyList<T>> GetAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.Where(e => !e.IsDeleted)
            .Where(predicate)
            .AsNoTracking()
            .ToListAsync();
    }

    public virtual async Task<IReadOnlyList<T>> GetAsync(Expression<Func<T, bool>>? predicate = null,
        Func<IQueryable<T>, IOrderedQueryable<T>>? orderBy = null,
        string? includeString = null,
        bool disableTracking = true)
    {
        IQueryable<T> query = _dbSet.Where(e => !e.IsDeleted);

        if (disableTracking) query = query.AsNoTracking();

        // İlişkili verileri eklemek için (Eager Loading)
        if (!string.IsNullOrWhiteSpace(includeString)) query = query.Include(includeString);

        // Filtreleme koşulu
        if (predicate != null) query = query.Where(predicate);

        // Sıralama koşulu
        if (orderBy != null)
            return await orderBy(query).ToListAsync();
        else
            return await query.ToListAsync();
    }

    public virtual async Task<IReadOnlyList<T>> GetAsync(Expression<Func<T, bool>>? predicate = null,
        Func<IQueryable<T>, IOrderedQueryable<T>>? orderBy = null,
        List<Expression<Func<T, object>>>? includes = null,
        bool disableTracking = true)
    {
        IQueryable<T> query = _dbSet.Where(e => !e.IsDeleted);

        if (disableTracking) query = query.AsNoTracking();

        // İlişkili verileri eklemek için (Eager Loading - Lambda Expressions)
        if (includes != null) query = includes.Aggregate(query, (current, include) => current.Include(include));

        // Filtreleme koşulu
        if (predicate != null) query = query.Where(predicate);

        // Sıralama koşulu
        if (orderBy != null)
            return await orderBy(query).ToListAsync();
        else
            return await query.ToListAsync();
    }

    // --- Write Operations ---

    public virtual async Task<T> AddAsync(T entity)
    {
        // BaseEntity içindeki CreatedAt ve IsDeleted varsayılan değerlerini alır.
        await _dbSet.AddAsync(entity);
        // Not: SaveChangesAsync burada çağrılmaz. Unit of Work veya Servis katmanında yönetilir.
        return entity;
    }

    public virtual Task UpdateAsync(T entity)
    {
        // UpdatedAt otomatik olarak ayarlanır.
        entity.UpdatedAt = DateTime.UtcNow;
        // Entity'nin durumunu Modified olarak işaretleriz.
        _dbContext.Entry(entity).State = EntityState.Modified;
        // Not: SaveChangesAsync burada çağrılmaz.
        return Task.CompletedTask;
    }

    public virtual async Task DeleteAsync(int id)
    {
        // Önce entity'yi buluruz (tracking açık olmalı ki değişiklik algılansın).
        // FindAsync tracking ile çalışır ve önce context'e bakar.
        var entity = await _dbSet.FindAsync(id);
        // Eğer context'te yoksa ve silinmemişse veritabanından çeker.
        // Ancak IsDeleted kontrolünü FindAsync yapmaz, bu yüzden ek kontrol gerekebilir.
        if (entity != null && !entity.IsDeleted)
        {
            await DeleteAsync(entity); // Bulunan entity üzerinden silme işlemi yapılır.
        }
        else if (entity != null && entity.IsDeleted)
        {
            // Zaten silinmiş, loglanabilir veya sessizce geçilebilir.
            Console.WriteLine($"Entity with ID {id} is already deleted.");
        }
        else
        {
            // Bulunamadı, loglanabilir veya istisna fırlatılabilir.
            Console.WriteLine($"Entity with ID {id} not found for deletion.");
        }
    }


    public virtual Task DeleteAsync(T entity)
    {
        // Soft Delete: IsDeleted flag'ini true yapar ve UpdatedAt'i günceller.
        entity.IsDeleted = true;
        entity.UpdatedAt = DateTime.UtcNow;
        // Durumu Modified olarak işaretleriz.
        _dbContext.Entry(entity).State = EntityState.Modified;
        // Not: SaveChangesAsync burada çağrılmaz.
        return Task.CompletedTask;
    }
}