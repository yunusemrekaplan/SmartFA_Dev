using System.Linq.Expressions;
using Application.Interfaces.Repositories;
using Core.Entities;
using Infrastructure.Persistence.Contexts;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence.Repositories;

/// <summary>
/// ITransactionRepository implementasyonu.
/// </summary>
public class TransactionRepository : BaseRepository<Transaction>, ITransactionRepository
{
    public TransactionRepository(ApplicationDbContext dbContext) : base(dbContext)
    {
    }

    public async Task<IReadOnlyList<Transaction>> GetTransactionsByUserIdFilteredAsync(
        int userId, int? accountId, int? categoryId, DateTime? startDate, DateTime? endDate,
        int pageNumber, int pageSize, string sortCriteria)
    {
        // İlişkili Account ve Category bilgilerini de getirmek için Include kullanılır.
        // IsDeleted kontrolü BaseRepository'den gelir.
        var query = _dbSet
            .Include(t => t.Account) // Navigation property isimleri doğru olmalı
            .Include(t => t.Category) // Navigation property isimleri doğru olmalı
            .Where(t => t.UserId == userId && !t.IsDeleted); // BaseEntity IsDeleted + UserId kontrolü

        // Filtrelemeler
        if (accountId.HasValue) query = query.Where(t => t.AccountId == accountId.Value);
        if (categoryId.HasValue) query = query.Where(t => t.CategoryId == categoryId.Value);
        if (startDate.HasValue)
            query = query.Where(t => t.TransactionDate.Date >= startDate.Value.Date); // Sadece tarih kısmı karşılaştırılır
        if (endDate.HasValue) query = query.Where(t => t.TransactionDate.Date <= endDate.Value.Date); // Sadece tarih kısmı karşılaştırılır

        // Sıralama
        // Sıralama kriteri "date_desc" veya "date_asc" şeklinde olabilir
        // Sıralama kriteri "amount_desc" veya "amount_asc" şeklinde olabilir
        query = sortCriteria switch
        {
            "date_asc" => query.OrderBy(t => t.TransactionDate),
            "date_desc" => query.OrderByDescending(t => t.TransactionDate),
            "amount_asc" => query.OrderBy(t => t.Amount),
            "amount_desc" => query.OrderByDescending(t => t.Amount),
            _ => query.OrderByDescending(t => t.TransactionDate) // Varsayılan sıralama
        };

        // Sayfalama
        var transactions = await query
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
        
        return transactions;
    }

    public async Task<IReadOnlyList<Transaction>> GetTransactionsByAccountIdAsync(int userId, int accountId)
    {
        return await GetAsync(predicate: t => t.UserId == userId && t.AccountId == accountId,
            orderBy: q => q.OrderByDescending(t => t.TransactionDate).ThenByDescending(t => t.CreatedAt),
            includes: new List<Expression<Func<Transaction, object>>> { t => t.Category }); // Kategori bilgisini de getir
    }

    public async Task<IReadOnlyList<Transaction>> GetTransactionsByCategoryIdAsync(int userId, int categoryId)
    {
        return await GetAsync(predicate: t => t.UserId == userId && t.CategoryId == categoryId,
            orderBy: q => q.OrderByDescending(t => t.TransactionDate).ThenByDescending(t => t.CreatedAt),
            includes: new List<Expression<Func<Transaction, object>>> { t => t.Account }); // Hesap bilgisini de getir
    }
}