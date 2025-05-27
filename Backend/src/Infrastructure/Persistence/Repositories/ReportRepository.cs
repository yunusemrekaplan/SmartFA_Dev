using Application.Interfaces.Repositories;
using Core.Entities;
using Core.Enums;
using Infrastructure.Persistence.Contexts;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence.Repositories;

/// <summary>
/// Rapor repository implementasyonu
/// </summary>
public class ReportRepository : BaseRepository<Report>, IReportRepository
{
    public ReportRepository(ApplicationDbContext context) : base(context)
    {
    }

    /// <summary>
    /// Kullanıcının raporlarını sayfalandırarak getirir
    /// </summary>
    public async Task<List<Report>> GetUserReportsAsync(int userId, int page, int pageSize)
    {
        return await _dbSet
            .Where(r => r.UserId == userId && !r.IsDeleted)
            .OrderByDescending(r => r.GeneratedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    /// <summary>
    /// Kullanıcının toplam rapor sayısını getirir
    /// </summary>
    public async Task<int> GetUserReportCountAsync(int userId)
    {
        return await _dbSet
            .CountAsync(r => r.UserId == userId && !r.IsDeleted);
    }

    /// <summary>
    /// Kullanıcının belirli bir raporunu getirir
    /// </summary>
    public async Task<Report?> GetUserReportByIdAsync(int userId, int reportId)
    {
        return await _dbSet
            .FirstOrDefaultAsync(r => r.Id == reportId && r.UserId == userId && !r.IsDeleted);
    }

    /// <summary>
    /// Belirli tarih aralığındaki işlemleri getirir
    /// </summary>
    public async Task<List<Transaction>> GetTransactionsByDateRangeAsync(
        int userId, DateTime startDate, DateTime endDate, 
        List<int>? categoryIds = null, List<int>? accountIds = null)
    {
        var query = _dbContext.Set<Transaction>()
            .Include(t => t.Category)
            .Include(t => t.Account)
            .Where(t => t.UserId == userId && 
                       !t.IsDeleted && 
                       t.TransactionDate >= startDate && 
                       t.TransactionDate <= endDate);

        if (categoryIds != null && categoryIds.Any())
        {
            query = query.Where(t => categoryIds.Contains(t.CategoryId));
        }

        if (accountIds != null && accountIds.Any())
        {
            query = query.Where(t => accountIds.Contains(t.AccountId));
        }

        return await query.OrderBy(t => t.TransactionDate).ToListAsync();
    }

    /// <summary>
    /// Belirli tarih aralığındaki bütçeleri getirir
    /// </summary>
    public async Task<List<Budget>> GetBudgetsByDateRangeAsync(
        int userId, DateTime startDate, DateTime endDate, List<int>? categoryIds = null)
    {
        var query = _dbContext.Set<Budget>()
            .Include(b => b.Category)
            .Where(b => b.UserId == userId && !b.IsDeleted);

        // Tarih aralığına göre filtreleme (ay/yıl bazında)
        var startYear = startDate.Year;
        var startMonth = startDate.Month;
        var endYear = endDate.Year;
        var endMonth = endDate.Month;

        query = query.Where(b => 
            (b.Year > startYear || (b.Year == startYear && b.Month >= startMonth)) &&
            (b.Year < endYear || (b.Year == endYear && b.Month <= endMonth)));

        if (categoryIds != null && categoryIds.Any())
        {
            query = query.Where(b => categoryIds.Contains(b.CategoryId));
        }

        return await query.ToListAsync();
    }

    /// <summary>
    /// Kullanıcının hesaplarını getirir
    /// </summary>
    public async Task<List<Account>> GetUserAccountsAsync(int userId, List<int>? accountIds = null)
    {
        var query = _dbContext.Set<Account>()
            .Where(a => a.UserId == userId && !a.IsDeleted);

        if (accountIds != null && accountIds.Any())
        {
            query = query.Where(a => accountIds.Contains(a.Id));
        }

        return await query.OrderBy(a => a.Name).ToListAsync();
    }

    /// <summary>
    /// Kullanıcının kategorilerini getirir
    /// </summary>
    public async Task<List<Category>> GetUserCategoriesAsync(
        int userId, CategoryType? type = null, List<int>? categoryIds = null)
    {
        var query = _dbContext.Set<Category>()
            .Where(c => (c.UserId == userId || c.IsPredefined) && !c.IsDeleted);

        if (type.HasValue)
        {
            query = query.Where(c => c.Type == type.Value);
        }

        if (categoryIds != null && categoryIds.Any())
        {
            query = query.Where(c => categoryIds.Contains(c.Id));
        }

        return await query.OrderBy(c => c.Name).ToListAsync();
    }

    /// <summary>
    /// Kategori bazlı işlem özetini getirir
    /// </summary>
    public async Task<List<CategorySummary>> GetCategoryAnalysisAsync(
        int userId, DateTime startDate, DateTime endDate, List<int>? categoryIds = null)
    {
        var query = _dbContext.Set<Transaction>()
            .Include(t => t.Category)
            .Where(t => t.UserId == userId && 
                       !t.IsDeleted && 
                       t.TransactionDate >= startDate && 
                       t.TransactionDate <= endDate);

        if (categoryIds != null && categoryIds.Any())
        {
            query = query.Where(t => categoryIds.Contains(t.CategoryId));
        }

        var categoryAnalysis = await query
            .GroupBy(t => new { t.CategoryId, t.Category.Name, t.Category.Type })
            .Select(g => new CategorySummary
            {
                CategoryId = g.Key.CategoryId,
                CategoryName = g.Key.Name,
                CategoryType = g.Key.Type,
                TotalAmount = g.Sum(t => t.Amount),
                TransactionCount = g.Count()
            })
            .ToListAsync();

        // Bütçe bilgilerini ekle
        var budgets = await GetBudgetsByDateRangeAsync(userId, startDate, endDate, categoryIds);
        var budgetDict = budgets
            .GroupBy(b => b.CategoryId)
            .ToDictionary(g => g.Key, g => g.Sum(b => b.Amount));

        foreach (var analysis in categoryAnalysis)
        {
            if (budgetDict.TryGetValue(analysis.CategoryId, out var budgetAmount))
            {
                analysis.BudgetAmount = budgetAmount;
            }
        }

        return categoryAnalysis;
    }

    /// <summary>
    /// Hesap bazlı işlem özetini getirir
    /// </summary>
    public async Task<List<AccountSummary>> GetAccountSummaryAsync(
        int userId, DateTime startDate, DateTime endDate, List<int>? accountIds = null)
    {
        var accounts = await GetUserAccountsAsync(userId, accountIds);
        var accountSummaries = new List<AccountSummary>();

        foreach (var account in accounts)
        {
            var transactions = await _dbContext.Set<Transaction>()
                .Include(t => t.Category)
                .Where(t => t.AccountId == account.Id && 
                           !t.IsDeleted && 
                           t.TransactionDate >= startDate && 
                           t.TransactionDate <= endDate)
                .ToListAsync();

            var incomeTransactions = transactions.Where(t => t.Category.Type == CategoryType.Income);
            var expenseTransactions = transactions.Where(t => t.Category.Type == CategoryType.Expense);

            accountSummaries.Add(new AccountSummary
            {
                AccountId = account.Id,
                AccountName = account.Name,
                AccountType = account.Type,
                InitialBalance = account.InitialBalance,
                TotalIncome = incomeTransactions.Sum(t => t.Amount),
                TotalExpense = expenseTransactions.Sum(t => t.Amount),
                TransactionCount = transactions.Count
            });
        }

        return accountSummaries;
    }

    /// <summary>
    /// Bütçe performans verilerini getirir
    /// </summary>
    public async Task<List<BudgetPerformance>> GetBudgetPerformanceAsync(
        int userId, DateTime startDate, DateTime endDate, List<int>? categoryIds = null)
    {
        var budgets = await GetBudgetsByDateRangeAsync(userId, startDate, endDate, categoryIds);
        var budgetPerformances = new List<BudgetPerformance>();

        foreach (var budget in budgets)
        {
            // Bu bütçe dönemindeki harcamaları hesapla
            var monthStart = new DateTime(budget.Year, budget.Month, 1);
            var monthEnd = monthStart.AddMonths(1).AddDays(-1);

            var spentAmount = await _dbContext.Set<Transaction>()
                .Where(t => t.UserId == userId && 
                           t.CategoryId == budget.CategoryId && 
                           !t.IsDeleted && 
                           t.TransactionDate >= monthStart && 
                           t.TransactionDate <= monthEnd)
                .SumAsync(t => t.Amount);

            budgetPerformances.Add(new BudgetPerformance
            {
                CategoryId = budget.CategoryId,
                CategoryName = budget.Category.Name,
                BudgetAmount = budget.Amount,
                SpentAmount = spentAmount,
                Month = budget.Month,
                Year = budget.Year
            });
        }

        return budgetPerformances;
    }
} 