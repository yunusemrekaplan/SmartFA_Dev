using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Debt;

/// <summary>
/// Yeni borç oluşturma isteği için DTO.
/// </summary>
public record CreateDebtDto(
    [Required] string Name,
    string? LenderName,
    [Required] decimal TotalAmount,
    [Required] decimal RemainingAmount,
    [Required] string Currency
);