using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Budget;

/// <summary>
/// Bütçe güncelleme isteği için DTO (Sadece tutar).
/// </summary>
public record UpdateBudgetDto(
    [Required] decimal Amount
);