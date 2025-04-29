using System.ComponentModel.DataAnnotations;
using Core.Enums;

namespace Application.DTOs.Category;

/// <summary>
/// Yeni kategori oluşturma isteği için DTO.
/// </summary>
public record CreateCategoryDto(
    [Required] string Name,
    [Required] CategoryType Type,
    [Required] string IconName // İkon seçimi zorunlu varsayıldı
);