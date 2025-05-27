namespace Application.DTOs.Reports;

public class ReportDataDto
{
    public ReportDto Report { get; set; } = null!;
    public FinancialSummaryDto Summary { get; set; } = null!;
    public List<ChartDataDto> Charts { get; set; } = new();
    public List<CategoryAnalysisDto> CategoryAnalysis { get; set; } = new();
    public List<AccountSummaryDto> AccountSummaries { get; set; } = new();
    public BudgetPerformanceDto? BudgetPerformance { get; set; }
}

public class FinancialSummaryDto
{
    public decimal TotalIncome { get; set; }
    public decimal TotalExpense { get; set; }
    public decimal NetAmount { get; set; }
    public decimal TotalBudget { get; set; }
    public decimal BudgetUtilization { get; set; }
    public int TransactionCount { get; set; }
}

public class ChartDataDto
{
    public string ChartType { get; set; } = null!; // "pie", "line", "bar"
    public string Title { get; set; } = null!;
    public List<ChartPointDto> Data { get; set; } = new();
}

public class ChartPointDto
{
    public string Label { get; set; } = null!;
    public decimal Value { get; set; }
    public string? Color { get; set; }
    public DateTime? Date { get; set; }
}

public class CategoryAnalysisDto
{
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = null!;
    public string CategoryType { get; set; } = null!;
    public decimal Amount { get; set; }
    public decimal Percentage { get; set; }
    public int TransactionCount { get; set; }
    public decimal? BudgetAmount { get; set; }
    public decimal? BudgetUtilization { get; set; }
}

public class AccountSummaryDto
{
    public int AccountId { get; set; }
    public string AccountName { get; set; } = null!;
    public string AccountType { get; set; } = null!;
    public decimal InitialBalance { get; set; }
    public decimal CurrentBalance { get; set; }
    public decimal TotalIncome { get; set; }
    public decimal TotalExpense { get; set; }
    public int TransactionCount { get; set; }
}

public class BudgetPerformanceDto
{
    public decimal TotalBudget { get; set; }
    public decimal TotalSpent { get; set; }
    public decimal Remaining { get; set; }
    public decimal UtilizationPercentage { get; set; }
    public List<BudgetCategoryDto> Categories { get; set; } = new();
}

public class BudgetCategoryDto
{
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = null!;
    public decimal BudgetAmount { get; set; }
    public decimal SpentAmount { get; set; }
    public decimal RemainingAmount { get; set; }
    public decimal UtilizationPercentage { get; set; }
    public bool IsOverBudget { get; set; }
} 