using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Core.Entities.Core;

/// <summary>
/// Tüm entity'ler için temel sınıf. Ortak alanları içerir.
/// </summary>
public abstract class BaseEntity
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)] // Otomatik artan ID
    public int Id { get; set; }

    [Required] public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; } // Nullable, ilk oluşturmada null olabilir

    [Required] public bool IsDeleted { get; set; } = false; // Soft delete için flag

    // Soft delete tarihi (opsiyonel, ihtiyaç halinde eklenebilir)
    // public DateTime? DeletedAt { get; set; }
}