using Core.Enums;

namespace Application.DTOs.Reports;

public class ReportDto
{
    public int Id { get; set; }
    public string Title { get; set; } = null!;
    public ReportType Type { get; set; }
    public string TypeName { get; set; } = null!;
    public ReportPeriod Period { get; set; }
    public string PeriodName { get; set; } = null!;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public string? Description { get; set; }
    public DateTime GeneratedAt { get; set; }
    public string? FilePath { get; set; }
    public bool IsScheduled { get; set; }
} 