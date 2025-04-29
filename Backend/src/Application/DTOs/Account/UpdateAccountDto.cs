using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Account;

/// <summary>
/// Hesap güncelleme isteği için DTO (Sadece isim güncellenir).
/// </summary>
public record UpdateAccountDto(
    [Required] string Name
);