using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Core.Entities.Core;
using Core.Enums;

namespace Core.Entities;

/// <summary>
/// Kullanıcı raporlarını temsil eder.
/// </summary>
public class Report : BaseEntity
{
    [Required] public int UserId { get; set; }
    [ForeignKey("UserId")] public virtual User User { get; set; } = null!;

    [Required] [MaxLength(200)] public string Title { get; set; } = null!;

    [Required] public ReportType Type { get; set; }

    [Required] public ReportPeriod Period { get; set; }

    [Required] public DateTime StartDate { get; set; }

    [Required] public DateTime EndDate { get; set; }

    [MaxLength(1000)] public string? Description { get; set; }

    public string? FilterCriteria { get; set; } // JSON format

    public DateTime GeneratedAt { get; set; }

    public string? FilePath { get; set; } // PDF/Excel dosya yolu

    public bool IsScheduled { get; set; } = false;

    public string? ScheduleCron { get; set; } // Cron expression for scheduled reports
}