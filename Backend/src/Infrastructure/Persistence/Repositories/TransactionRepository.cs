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
        int pageNumber, int pageSize)
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

        // Sayfalama
        // Önce sıralama yapılmalı (genellikle tarihe göre tersten)
        query = query.OrderByDescending(t => t.TransactionDate)
            .ThenByDescending(t => t.CreatedAt); // Aynı gün içindekileri eklenme sırasına göre sırala

        // Skip ve Take ile sayfalama uygulanır.
        return await query.Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .AsNoTracking() // Sonuç listesi okunacağı için tracking kapatılır.
            .ToListAsync();
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