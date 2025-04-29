namespace Application.DTOs.Debt;

/// <summary>
/// Borç bilgilerini temsil eden DTO.
/// </summary>
public record DebtDto(
    int Id,
    string Name,
    string? LenderName,
    decimal TotalAmount,
    decimal RemainingAmount,
    string Currency,
    bool IsPaidOff // Tamamen ödendi mi?
);