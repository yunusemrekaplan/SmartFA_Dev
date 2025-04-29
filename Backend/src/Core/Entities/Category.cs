using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Core.Entities.Core;
using Core.Enums;

namespace Core.Entities;

/// <summary>
/// Gelir veya Gider Kategorilerini temsil eder.
/// </summary>
public class Category : BaseEntity
{
    [Required] [MaxLength(100)] public string Name { get; set; } = null!; // Null forgiveness operatörü veya constructor'da atama

    [Required] public CategoryType Type { get; set; }

    [MaxLength(50)] public string? IconName { get; set; }

    public bool IsPredefined { get; set; } = false;

    // Kullanıcıya özel kategoriler için User ilişkisi (nullable FK)
    public int? UserId { get; set; } // Nullable int FK
    [ForeignKey("UserId")] public virtual User? User { get; set; } // Navigation Property (nullable olabilir)

    // Navigation Properties
    public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public virtual ICollection<Budget> Budgets { get; set; } = new List<Budget>();
}