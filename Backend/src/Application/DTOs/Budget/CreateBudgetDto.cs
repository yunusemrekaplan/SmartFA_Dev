using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Budget;

/// <summary>
/// Yeni bütçe oluşturma isteği için DTO.
/// </summary>
public record CreateBudgetDto(
    [Required] int CategoryId,
    [Required] decimal Amount,
    [Required] int Month,
    [Required] int Year
);