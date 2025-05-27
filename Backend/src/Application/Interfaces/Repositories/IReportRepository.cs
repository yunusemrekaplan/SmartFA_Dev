using Core.Entities;
using Core.Enums;

namespace Application.Interfaces.Repositories;

/// <summary>
/// Rapor verilerine erişim için repository interface'i
/// </summary>
public interface IReportRepository : IRepository<Report>
{
    /// <summary>
    /// Kullanıcının raporlarını sayfalandırarak getirir
    /// </summary>
    Task<List<Report>> GetUserReportsAsync(int userId, int page, int pageSize);

    /// <summary>
    /// Kullanıcının toplam rapor sayısını getirir
    /// </summary>
    Task<int> GetUserReportCountAsync(int userId);

    /// <summary>
    /// Kullanıcının belirli bir raporunu getirir
    /// </summary>
    Task<Report?> GetUserReportByIdAsync(int userId, int reportId);

    /// <summary>
    /// Belirli tarih aralığındaki işlemleri getirir
    /// </summary>
    Task<List<Transaction>> GetTransactionsByDateRangeAsync(int userId, DateTime startDate, DateTime endDate, List<int>? categoryIds = null, List<int>? accountIds = null);

    /// <summary>
    /// Belirli tarih aralığındaki bütçeleri getirir
    /// </summary>
    Task<List<Budget>> GetBudgetsByDateRangeAsync(int userId, DateTime startDate, DateTime endDate, List<int>? categoryIds = null);

    /// <summary>
    /// Kullanıcının hesaplarını getirir
    /// </summary>
    Task<List<Account>> GetUserAccountsAsync(int userId, List<int>? accountIds = null);

    /// <summary>
    /// Kullanıcının kategorilerini getirir
    /// </summary>
    Task<List<Category>> GetUserCategoriesAsync(int userId, CategoryType? type = null, List<int>? categoryIds = null);

    /// <summary>
    /// Kategori bazlı işlem özetini getirir
    /// </summary>
    Task<List<CategorySummary>> GetCategoryAnalysisAsync(int userId, DateTime startDate, DateTime endDate, List<int>? categoryIds = null);

    /// <summary>
    /// Hesap bazlı işlem özetini getirir
    /// </summary>
    Task<List<AccountSummary>> GetAccountSummaryAsync(int userId, DateTime startDate, DateTime endDate, List<int>? accountIds = null);

    /// <summary>
    /// Bütçe performans verilerini getirir
    /// </summary>
    Task<List<BudgetPerformance>> GetBudgetPerformanceAsync(int userId, DateTime startDate, DateTime endDate, List<int>? categoryIds = null);
}

/// <summary>
/// Kategori özet verisi
/// </summary>
public class CategorySummary
{
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = null!;
    public CategoryType CategoryType { get; set; }
    public decimal TotalAmount { get; set; }
    public int TransactionCount { get; set; }
    public decimal? BudgetAmount { get; set; }
}

/// <summary>
/// Hesap özet verisi
/// </summary>
public class AccountSummary
{
    public int AccountId { get; set; }
    public string AccountName { get; set; } = null!;
    public AccountType AccountType { get; set; }
    public decimal InitialBalance { get; set; }
    public decimal TotalIncome { get; set; }
    public decimal TotalExpense { get; set; }
    public int TransactionCount { get; set; }
}

/// <summary>
/// Bütçe performans verisi
/// </summary>
public class BudgetPerformance
{
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = null!;
    public decimal BudgetAmount { get; set; }
    public decimal SpentAmount { get; set; }
    public int Month { get; set; }
    public int Year { get; set; }
} 