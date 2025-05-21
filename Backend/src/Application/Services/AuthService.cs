using System.IdentityModel.Tokens.Jwt;
using System.Linq.Expressions;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Application.DTOs.Authentication;
using Application.Interfaces;
using Application.Interfaces.Services;
using Application.Wrappers;
using AutoMapper;
using Core.Entities;
using FluentValidation;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;

namespace Application.Services;

/// <summary>
/// IAuthService implementasyonu (JWT, Refresh Token ve Örnek Şifreleme ile).
/// </summary>
public class AuthService : IAuthService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IConfiguration _configuration;
    private readonly IValidator<RegisterDto> _registerValidator;
    private readonly IValidator<LoginDto> _loginValidator;
    private readonly ILogger<AuthService> _logger;
    private readonly IMapper _mapper; // Gerekirse DTO dönüşümü için

    // Refresh token ömrünü appsettings'den almak için (gün cinsinden)
    private readonly int _refreshTokenTtlDays;

    // Access token ömrünü appsettings'den almak için (dakika cinsinden)
    private readonly int _accessTokenTtlMinutes;


    public AuthService(
        IUnitOfWork unitOfWork,
        IConfiguration configuration,
        IValidator<RegisterDto> registerValidator,
        IValidator<LoginDto> loginValidator,
        ILogger<AuthService> logger,
        IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _configuration = configuration;
        _registerValidator = registerValidator;
        _loginValidator = loginValidator;
        _logger = logger;
        _mapper = mapper; // Mapper inject edildi

        // Token ömürlerini oku (varsayılan değerlerle)
        _refreshTokenTtlDays = Convert.ToInt32(_configuration["JwtSettings:RefreshTokenTTLDays"] ?? "7");
        _accessTokenTtlMinutes = Convert.ToInt32(_configuration["JwtSettings:ExpirationMinutes"] ?? "15");
    }

    public async Task<Result<AuthResponseDto>> RegisterAsync(RegisterDto registerDto)
    {
        var validationResult = await _registerValidator.ValidateAsync(registerDto);
        if (!validationResult.IsValid)
        {
            return Result<AuthResponseDto>.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            var existingUser = await _unitOfWork.Users.GetByEmailAsync(registerDto.Email);
            if (existingUser != null)
            {
                return Result<AuthResponseDto>.Failure("Bu e-posta adresi zaten kullanılıyor.");
            }

            string passwordHash = BCrypt.Net.BCrypt.HashPassword(registerDto.Password);

            var newUser = new User
            {
                Email = registerDto.Email.ToLowerInvariant(),
                PasswordHash = passwordHash,
                RegisteredAt = DateTime.UtcNow
            };

            var addedUser = await _unitOfWork.Users.AddAsync(newUser);
            // Kullanıcıyı kaydet ki ID'si oluşsun ve Refresh Token eklenebilsin
            await _unitOfWork.CompleteAsync();

            // Tokenları oluştur ve kaydet
            var tokens = await GenerateAndSaveTokens(addedUser);
            // Token kaydını da tamamla
            await _unitOfWork.CompleteAsync();

            return Result<AuthResponseDto>.Success(tokens);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı kaydı sırasında hata oluştu: {Email}", registerDto.Email);
            return Result<AuthResponseDto>.Failure("Kayıt sırasında bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<AuthResponseDto>> LoginAsync(LoginDto loginDto)
    {
        var validationResult = await _loginValidator.ValidateAsync(loginDto);
        if (!validationResult.IsValid)
        {
            return Result<AuthResponseDto>.Failure(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        try
        {
            var user = await _unitOfWork.Users.GetByEmailAsync(loginDto.Email);
            if (user == null)
            {
                return Result<AuthResponseDto>.Failure("Geçersiz e-posta veya şifre.");
            }

            bool isPasswordValid = BCrypt.Net.BCrypt.Verify(loginDto.Password, user.PasswordHash);
            if (!isPasswordValid)
            {
                return Result<AuthResponseDto>.Failure("Geçersiz e-posta veya şifre.");
            }

            // Tokenları oluştur ve kaydet
            var tokens = await GenerateAndSaveTokens(user);
            // Token kaydını tamamla
            await _unitOfWork.CompleteAsync();

            return Result<AuthResponseDto>.Success(tokens);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı girişi sırasında hata oluştu: {Email}", loginDto.Email);
            return Result<AuthResponseDto>.Failure("Giriş sırasında bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result<AuthResponseDto>> RefreshTokenAsync(string refreshToken)
    {
        if (string.IsNullOrWhiteSpace(refreshToken))
        {
            return Result<AuthResponseDto>.Failure("Refresh token gereklidir.");
        }

        try
        {
            // Veritabanından refresh token'ı bul (ilişkili User ile birlikte)
            var storedToken = await _unitOfWork.UserRefreshTokens.GetByTokenAsync(refreshToken);

            if (storedToken == null)
            {
                return Result<AuthResponseDto>.Failure("Geçersiz refresh token.");
            }

            if (storedToken.IsRevoked)
            {
                _logger.LogWarning("İptal edilmiş refresh token kullanılmaya çalışıldı: UserId {UserId}, Token {Token}", storedToken.UserId,
                    refreshToken);
                await RevokeAllUserTokens(storedToken.UserId); // Diğer tokenları iptal et
                await _unitOfWork.CompleteAsync(); // İptalleri kaydet
                return Result<AuthResponseDto>.Failure("Refresh token iptal edilmiş.");
            }

            if (storedToken.IsExpired)
            {
                return Result<AuthResponseDto>.Failure("Refresh token süresi dolmuş.");
            }

            // Eski token'ı iptal et (henüz SaveChanges yapma)
            storedToken.RevokedAt = DateTime.UtcNow;
            await _unitOfWork.UserRefreshTokens.UpdateAsync(storedToken);

            // Yeni token çifti oluştur ve kaydet (henüz SaveChanges yapma)
            var newTokens = await GenerateAndSaveTokens(storedToken.User);

            // Tüm değişiklikleri (eski token iptali ve yeni token ekleme) kaydet
            await _unitOfWork.CompleteAsync();

            return Result<AuthResponseDto>.Success(newTokens);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Token yenileme sırasında hata oluştu.");
            return Result<AuthResponseDto>.Failure("Token yenileme sırasında bir sunucu hatası oluştu.");
        }
    }

    public async Task<Result> RevokeTokenAsync(string refreshToken)
    {
        if (string.IsNullOrWhiteSpace(refreshToken))
        {
            return Result.Failure("Refresh token gereklidir.");
        }

        try
        {
            // Token'ı bul (Update için tracking açık olmalı)
            var storedToken =
                await _unitOfWork.UserRefreshTokens
                    .GetByTokenAsync(refreshToken); // GetByTokenAsync tracking ile getiriyor mu kontrol etmeli (Evet, Include var)
            // Veya:
            // var storedToken = (await _unitOfWork.UserRefreshTokens.GetWhereAsync(rt => rt.Token == refreshToken, false)).FirstOrDefault();

            if (storedToken == null || !storedToken.IsActive) // Aktif değilse (iptal edilmiş veya süresi dolmuş)
            {
                return Result.Failure("Geçersiz veya aktif olmayan refresh token.");
            }

            // Token'ı iptal et
            storedToken.RevokedAt = DateTime.UtcNow;
            await _unitOfWork.UserRefreshTokens.UpdateAsync(storedToken);
            await _unitOfWork.CompleteAsync(); // Değişikliği kaydet

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Token iptali sırasında hata oluştu.");
            return Result.Failure("Token iptali sırasında bir sunucu hatası oluştu.");
        }
    }


    // --- Yardımcı Metotlar ---

    /// <summary>
    /// Belirli bir kullanıcı için yeni Access ve Refresh token üretir,
    /// Refresh token'ı veritabanına ekler (henüz kaydetmez) ve AuthResponseDto döndürür.
    /// </summary>
    private async Task<AuthResponseDto> GenerateAndSaveTokens(User user)
    {
        var accessToken = GenerateJwtAccessToken(user);
        var refreshTokenData = GenerateRefreshToken(); // (string Token, DateTime ExpiresAt) döner

        var userRefreshToken = new UserRefreshToken
        {
            UserId = user.Id,
            Token = refreshTokenData.Token,
            ExpiresAt = refreshTokenData.ExpiresAt,
            CreatedAt = DateTime.UtcNow
        };

        // Repository'ye ekle (henüz SaveChanges yok)
        await _unitOfWork.UserRefreshTokens.AddAsync(userRefreshToken);

        return new AuthResponseDto(accessToken, user.Id.ToString(), user.Email, refreshTokenData.Token);
    }


    // JWT Access Token Oluşturma
    private string GenerateJwtAccessToken(User user)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var secret = jwtSettings["Secret"] ?? throw new InvalidOperationException("JWT Secret not configured.");
        var issuer = jwtSettings["Issuer"];
        var audience = jwtSettings["Audience"];
        // Access token ömrünü oku (dakika)
        var expirationMinutes = _accessTokenTtlMinutes;

        var key = Encoding.ASCII.GetBytes(secret);
        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            }),
            Expires = DateTime.UtcNow.AddMinutes(expirationMinutes), // Kısa ömürlü access token
            Issuer = issuer,
            Audience = audience,
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
        };
        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }

    // Güvenli Refresh Token Oluşturma
    private (string Token, DateTime ExpiresAt) GenerateRefreshToken()
    {
        var randomNumber = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomNumber);
        var refreshToken = Convert.ToBase64String(randomNumber);
        // Refresh token ömrünü kullan (gün)
        var expiresAt = DateTime.UtcNow.AddDays(_refreshTokenTtlDays);

        return (refreshToken, expiresAt);
    }

    // Belirli bir kullanıcının tüm aktif refresh token'larını iptal etme
    private async Task RevokeAllUserTokens(int userId)
    {
        // Aktif tokenları bul (tracking açık)
        var userTokens = await _unitOfWork.UserRefreshTokens.GetWhereAsync(rt => rt.UserId == userId && rt.IsActive, false);
        foreach (var token in userTokens)
        {
            token.RevokedAt = DateTime.UtcNow;
            await _unitOfWork.UserRefreshTokens.UpdateAsync(token); // State'i Modified yapar
        }
        // SaveChanges çağıran metotta yapılmalı (RefreshTokenAsync içinde)
    }
    
    // Verilen refresh token ile ilişkili kullanıcı ID'sini alır
    public async Task<int?> GetUserIdFromRefreshTokenAsync(string refreshToken)
    {
        if (string.IsNullOrWhiteSpace(refreshToken))
        {
            return null;
        }

        var storedToken = await _unitOfWork.UserRefreshTokens.GetByTokenAsync(refreshToken);
        return storedToken?.UserId;
    }
}