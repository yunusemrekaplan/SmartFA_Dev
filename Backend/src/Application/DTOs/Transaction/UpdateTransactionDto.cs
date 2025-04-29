using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Transaction;

/// <summary>
/// İşlem güncelleme isteği için DTO.
/// </summary>
public record UpdateTransactionDto(
    [Required] int AccountId,
    [Required] int CategoryId,
    [Required] decimal Amount,
    [Required] DateTime TransactionDate,
    string? Notes
);