using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Core.Entities.Core;

namespace Core.Entities;

/// <summary>
/// Tek bir finansal işlemi temsil eder.
/// </summary>
public class Transaction : BaseEntity
{
    [Required] public int UserId { get; set; }
    [ForeignKey("UserId")] public virtual User User { get; set; } = null!;

    [Required] public int AccountId { get; set; }
    [ForeignKey("AccountId")] public virtual Account Account { get; set; } = null!;

    [Required] public int CategoryId { get; set; }
    [ForeignKey("CategoryId")] public virtual Category Category { get; set; } = null!;

    [Required]
    [Column(TypeName = "decimal(18, 2)")]
    public decimal Amount { get; set; }

    [Required] public DateTime TransactionDate { get; set; }

    [MaxLength(500)] public string? Notes { get; set; }
}