using Core.Enums;

namespace Application.DTOs.Reports;

public class CreateReportRequestDto
{
    public string Title { get; set; } = null!;
    public ReportType Type { get; set; }
    public ReportPeriod Period { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public string? Description { get; set; }
    public ReportFormat Format { get; set; } = ReportFormat.JSON;
    public ReportFilterDto? Filters { get; set; }
    public bool SaveReport { get; set; } = true;
}

public class ReportFilterDto
{
    public List<int>? CategoryIds { get; set; }
    public List<int>? AccountIds { get; set; }
    public decimal? MinAmount { get; set; }
    public decimal? MaxAmount { get; set; }
    public bool IncludeIncome { get; set; } = true;
    public bool IncludeExpense { get; set; } = true;
} 