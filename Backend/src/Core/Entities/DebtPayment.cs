using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Core.Entities.Core;

namespace Core.Entities;

/// <summary>
/// Bir borca yapılan ödemeyi temsil eder.
/// </summary>
public class DebtPayment : BaseEntity
{
    [Required] public int DebtId { get; set; }
    [ForeignKey("DebtId")] public virtual Debt Debt { get; set; } = null!;

    [Required]
    [Column(TypeName = "decimal(18, 2)")]
    public decimal Amount { get; set; }

    [Required] public DateTime PaymentDate { get; set; }

    [MaxLength(200)] public string? Notes { get; set; }
}