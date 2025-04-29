using Application.DTOs.Authentication;
using Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

/// <summary>
/// Kimlik doğrulama, kullanıcı kaydı ve token işlemleri için controller.
/// </summary>
public class AuthController : BaseApiController
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    /// <summary>
    /// Yeni kullanıcı kaydı yapar ve token çifti döndürür.
    /// </summary>
    [HttpPost("register")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)] // Artık RefreshToken da içeriyor
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterDto registerDto)
    {
        var result = await _authService.RegisterAsync(registerDto);
        return HandleResult(result);
    }

    /// <summary>
    /// Kullanıcı girişi yapar ve token çifti döndürür.
    /// </summary>
    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)] // Artık RefreshToken da içeriyor
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Login([FromBody] LoginDto loginDto)
    {
        var result = await _authService.LoginAsync(loginDto);
        return HandleResult(result);
    }

    /// <summary>
    /// Verilen refresh token kullanarak yeni bir access ve refresh token çifti alır.
    /// </summary>
    [HttpPost("refresh")]
    [AllowAnonymous] // Bu endpoint'e erişim için geçerli bir access token gerekmez
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)] // Geçersiz/süresi dolmuş token vb.
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequestDto requestDto)
    {
        if (string.IsNullOrWhiteSpace(requestDto.RefreshToken))
        {
            return BadRequest("Refresh token gereklidir.");
        }

        var result = await _authService.RefreshTokenAsync(requestDto.RefreshToken);
        return HandleResult(result);
    }

    /// <summary>
    /// Belirtilen refresh token'ı iptal eder (geçersiz kılar).
    /// </summary>
    /// <remarks>
    /// Genellikle çıkış yapma (logout) senaryosunda kullanılır.
    /// </remarks>
    [HttpPost("revoke")]
    [Authorize] // Token iptali için kullanıcının giriş yapmış olması (geçerli access token) GEREKEBİLİR
    // veya AllowAnonymous yapılıp sadece refresh token ile de iptal edilebilir.
    // Güvenlik açısından Authorize daha mantıklı olabilir.
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)] // Geçersiz token vb.
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> RevokeToken([FromBody] RefreshTokenRequestDto requestDto)
    {
        if (string.IsNullOrWhiteSpace(requestDto.RefreshToken))
        {
            return BadRequest("Refresh token gereklidir.");
        }

        // Opsiyonel: Token'daki kullanıcı ID'si ile refresh token'ın sahibi eşleşiyor mu kontrolü
        // var userIdFromToken = GetUserIdFromToken();
        // ... (Token'ı DB'den çekip UserId'sini kontrol et) ...

        var result = await _authService.RevokeTokenAsync(requestDto.RefreshToken);
        return HandleResult(result);
    }
}