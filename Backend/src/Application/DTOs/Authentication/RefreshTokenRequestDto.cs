using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Authentication;

public record RefreshTokenRequestDto([Required] string RefreshToken);