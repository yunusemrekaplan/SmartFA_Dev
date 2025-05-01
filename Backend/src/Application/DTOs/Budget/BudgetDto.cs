namespace Application.DTOs.Budget;

/// <summary>
/// Bütçe bilgilerini temsil eden DTO (Harcanan/Kalan dahil).
/// </summary>
public record BudgetDto
{
    public int Id { get; init; } // Bütçe ID'si
    public int CategoryId { get; init; } // İlişkili kategori ID'si
    public string CategoryName { get; init; } // İlişkili kategori adı
    public string? CategoryIcon { get; init; } // İlişkili kategori ikonu
    public decimal Amount { get; init; } // Bütçe tutarı
    public int Month { get; init; } // Bütçe ayı
    public int Year { get; init; } // Bütçe yılı
    public decimal SpentAmount { get; init; } // Harcanan tutar
    public decimal RemainingAmount { get; init; } // Kalan tutar

    public BudgetDto()
    {
    }
}