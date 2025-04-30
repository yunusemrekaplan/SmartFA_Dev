using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Core.Entities.Core;

namespace Core.Entities;

/// <summary>
/// Kullanıcıların JWT Refresh Token'larını saklamak için entity.
/// </summary>
public class UserRefreshToken : BaseEntity
{
    [Required] public int UserId { get; set; } // Hangi kullanıcıya ait olduğu
    [ForeignKey("UserId")] public virtual User User { get; set; } = null!; // Navigation property

    [Required]
    [MaxLength(256)] // Token uzunluğuna göre ayarlanabilir
    public string Token { get; set; } = null!; // Refresh token değeri

    [Required] public DateTime ExpiresAt { get; set; } // Token'ın son kullanma tarihi

    public DateTime? RevokedAt { get; set; } // Token'ın iptal edilme tarihi (varsa)

    // Token'ın aktif olup olmadığını kontrol eden computed property
    public bool IsExpired => DateTime.UtcNow >= ExpiresAt;
    public bool IsRevoked => RevokedAt != null;
    public bool IsActive => !IsRevoked && !IsExpired;

    // Güvenlik için: Bu token yerine geçen yeni token (opsiyonel)
    // public string? ReplacedByToken { get; set; }
}