using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Core.Entities.Core;

namespace Core.Entities;

/// <summary>
/// Belirli bir kategori için aylık bütçeyi temsil eder.
/// </summary>
public class Budget : BaseEntity
{
    [Required] public int UserId { get; set; }
    [ForeignKey("UserId")] public virtual User User { get; set; } = null!;

    [Required] public int CategoryId { get; set; } // Sadece Gider Kategorileri
    [ForeignKey("CategoryId")] public virtual Category Category { get; set; } = null!;

    [Required]
    [Column(TypeName = "decimal(18, 2)")]
    public decimal Amount { get; set; }

    [Required] public int Month { get; set; }

    [Required] public int Year { get; set; }
}