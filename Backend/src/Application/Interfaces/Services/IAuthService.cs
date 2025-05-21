using Application.DTOs.Authentication;
using Application.Wrappers;

namespace Application.Interfaces.Services;

/// <summary>
/// Authentication (JWT) ve kullanıcı yönetimi operasyonlarını tanımlar.
/// Refresh Token mekanizmasını içerir.
/// </summary>
public interface IAuthService
{
    /// <summary>
    /// Yeni kullanıcı kaydı yapar.
    /// </summary>
    /// <param name="registerDto">Kayıt bilgileri</param>
    /// <returns>Access/Refresh token ve kullanıcı bilgileri veya hata sonucu</returns>
    Task<Result<AuthResponseDto>> RegisterAsync(RegisterDto registerDto);

    /// <summary>
    /// Kullanıcı girişi yapar ve Access/Refresh token döndürür.
    /// </summary>
    /// <param name="loginDto">Giriş bilgileri</param>
    /// <returns>Access/Refresh token ve kullanıcı bilgileri veya hata sonucu</returns>
    Task<Result<AuthResponseDto>> LoginAsync(LoginDto loginDto);

    /// <summary>
    /// Verilen geçerli bir refresh token kullanarak yeni bir access ve refresh token çifti alır.
    /// </summary>
    /// <param name="refreshToken">Yenilemek için kullanılacak refresh token.</param>
    /// <returns>Yeni Access/Refresh token ve kullanıcı bilgileri veya hata sonucu</returns>
    Task<Result<AuthResponseDto>> RefreshTokenAsync(string refreshToken);

    /// <summary>
    /// Belirtilen refresh token'ı geçersiz kılar (iptal eder).
    /// </summary>
    /// <param name="refreshToken">İptal edilecek refresh token.</param>
    /// <returns>Başarı veya hata sonucu</returns>
    Task<Result> RevokeTokenAsync(string refreshToken);

    /// <summary>
    /// Verilen refresh token ile ilişkili kullanıcı ID'sini alır.
    /// </summary>
    /// <param name="requestDtoRefreshToken">Refresh token</param>
    /// <returns>Kullanıcı ID'si veya null</returns>
    Task<int?> GetUserIdFromRefreshTokenAsync(string requestDtoRefreshToken);
}