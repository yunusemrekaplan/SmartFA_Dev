using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Category;

/// <summary>
/// Kategori güncelleme isteği için DTO.
/// </summary>
public record UpdateCategoryDto(
    [Required] string Name,
    [Required] string IconName
);