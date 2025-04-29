using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Core.Entities;

/// <summary>
/// Uygulama kullanıcısını temsil eder.
/// </summary>
public class User
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)] // Otomatik artan ID
    public int Id { get; set; }

    [Required]
    [EmailAddress]
    [MaxLength(256)]
    public string Email { get; set; } = null!; // Null forgiveness operatörü veya constructor'da atama

    [Required] public string PasswordHash { get; set; } = null!; // Null forgiveness operatörü veya constructor'da atama

    [MaxLength(100)] public string? FullName { get; set; }

    [MaxLength(3)] public string? DefaultCurrency { get; set; } = "TRY";

    public DateTime RegisteredAt { get; set; } = DateTime.UtcNow;

    // Kullanıcı deaktifleştirme için (soft delete alternatifi)
    // public bool IsActive { get; set; } = true;

    // Navigation Properties
    public virtual ICollection<UserRefreshToken> RefreshTokens { get; set; } = new List<UserRefreshToken>();
    public virtual ICollection<Account> Accounts { get; set; } = new List<Account>();
    public virtual ICollection<Category> Categories { get; set; } = new List<Category>();
    public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public virtual ICollection<Budget> Budgets { get; set; } = new List<Budget>();
    public virtual ICollection<Debt> Debts { get; set; } = new List<Debt>();
}