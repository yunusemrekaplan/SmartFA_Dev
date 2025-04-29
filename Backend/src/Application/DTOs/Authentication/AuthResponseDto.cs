namespace Application.DTOs.Authentication;

/// <summary>
/// Başarılı kimlik doğrulama sonrası döndürülecek yanıt DTO'su.
/// </summary>
public record AuthResponseDto(
    string AccessToken, // Adı AccessToken olarak değiştirildi
    string UserId,
    string Email,
    string RefreshToken // RefreshToken eklendi
);