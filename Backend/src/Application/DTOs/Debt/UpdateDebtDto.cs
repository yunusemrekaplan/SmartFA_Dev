using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Debt;

/// <summary>
/// Borç güncelleme isteği için DTO (Sadece Ad ve Alacaklı).
/// </summary>
public record UpdateDebtDto(
    [Required] string Name,
    string? LenderName
);