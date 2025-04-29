namespace Application.DTOs.DebtPayment;

/// <summary>
/// Borç ödeme bilgilerini temsil eden DTO.
/// </summary>
public record DebtPaymentDto(
    int Id,
    int DebtId,
    decimal Amount,
    DateTime PaymentDate,
    string? Notes
);