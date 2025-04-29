using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Authentication;

/// <summary>
/// Kullanıcı giriş isteği için DTO.
/// </summary>
public record LoginDto(
    [Required] string Email,
    [Required] string Password
);