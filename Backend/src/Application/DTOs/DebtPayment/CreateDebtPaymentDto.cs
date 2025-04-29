using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.DebtPayment;

/// <summary>
/// Yeni borç ödemesi oluşturma isteği için DTO.
/// </summary>
public record CreateDebtPaymentDto(
    [Required] int DebtId,
    [Required] decimal Amount,
    [Required] DateTime PaymentDate,
    string? Notes
);