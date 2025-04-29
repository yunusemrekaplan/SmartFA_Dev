using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Core.Entities.Core;

namespace Core.Entities;

/// <summary>
/// Kullanıcının borçlarını temsil eder.
/// </summary>
public class Debt : BaseEntity
{
    [Required] public int UserId { get; set; }
    [ForeignKey("UserId")] public virtual User User { get; set; } = null!;

    [Required] [MaxLength(150)] public string Name { get; set; } = null!;

    [MaxLength(100)] public string? LenderName { get; set; }

    [Required]
    [Column(TypeName = "decimal(18, 2)")]
    public decimal TotalAmount { get; set; }

    [Required]
    [Column(TypeName = "decimal(18, 2)")]
    public decimal RemainingAmount { get; set; }

    [Required] [MaxLength(3)] public string Currency { get; set; } = "TRY";

    public bool IsPaidOff { get; set; } = false; // Borç tamamen ödendi mi?

    // Navigation Properties
    public virtual ICollection<DebtPayment> Payments { get; set; } = new List<DebtPayment>();
}