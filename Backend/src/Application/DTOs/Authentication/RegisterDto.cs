using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Authentication;

/// <summary>
/// Kullanıcı kayıt isteği için DTO.
/// </summary>
public record RegisterDto(
    [Required] string Email,
    [Required] string Password,
    [Required] string ConfirmPassword
);