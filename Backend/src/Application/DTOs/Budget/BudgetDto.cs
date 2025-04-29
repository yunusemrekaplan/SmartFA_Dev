namespace Application.DTOs.Budget;

/// <summary>
/// Bütçe bilgilerini temsil eden DTO (Harcanan/Kalan dahil).
/// </summary>
public record BudgetDto(
    int Id,
    int CategoryId,
    string CategoryName, // İlişkili kategori adı
    string? CategoryIcon, // İlişkili kategori ikonu
    decimal Amount, // Bütçe limiti
    int Month,
    int Year,
    decimal SpentAmount, // Hesaplanan harcanan tutar
    decimal RemainingAmount // Hesaplanan kalan tutar
);