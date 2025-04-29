using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Transaction;

/// <summary>
/// Yeni işlem oluşturma isteği için DTO.
/// </summary>
public record CreateTransactionDto(
    [Required] int AccountId,
    [Required] int CategoryId,
    [Required] decimal Amount,
    [Required] DateTime TransactionDate,
    string? Notes
);