using Core.Enums;

namespace Application.DTOs.Category;

/// <summary>
/// Kategori bilgilerini temsil eden DTO.
/// </summary>
public record CategoryDto(
    int Id,
    string Name,
    CategoryType Type,
    string? IconName,
    bool IsPredefined // Ön tanımlı mı?
);