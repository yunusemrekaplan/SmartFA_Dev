using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Core.Entities.Core;
using Core.Enums;

namespace Core.Entities;

/// <summary>
/// Kullanıcının finansal hesaplarını temsil eder.
/// </summary>
public class Account : BaseEntity
{
    [Required] public int UserId { get; set; }
    [ForeignKey("UserId")] public virtual User User { get; set; } = null!; // Navigation property null olmamalı

    [Required] [MaxLength(100)] public string Name { get; set; } = null!; // Null forgiveness operatörü veya constructor'da atama

    [Required] public AccountType Type { get; set; }

    [Required] [MaxLength(3)] public string Currency { get; set; } = "TRY";

    [Required]
    [Column(TypeName = "decimal(18, 2)")]
    public decimal InitialBalance { get; set; }

    // Navigation Properties
    // Not: İlişkili Transaction'lar sorgulanırken Account'un IsDeleted durumu kontrol edilmeli.
    public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
}