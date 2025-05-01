using Core.Enums;

namespace Application.DTOs.Transaction;

/// <summary>
/// İşlem bilgilerini temsil eden DTO (Listeleme ve Detay).
/// </summary>
public record TransactionDto
{
    public int Id { get; init; } // İşlem ID'si
    public int AccountId { get; init; } // İlişkili hesap ID'si
    public string AccountName { get; init; } // İlişkili hesap adı
    public int CategoryId { get; init; } // İlişkili kategori ID'si
    public string CategoryName { get; init; } // İlişkili kategori adı
    public string? CategoryIcon { get; init; } // İlişkili kategori ikonu
    public CategoryType CategoryType { get; init; } // Kategori türü (Gider/Gelir)

    public decimal Amount { get; init; } // İşlem tutarı
    public DateTime TransactionDate { get; init; } // İşlem tarihi
    public string? Notes { get; init; } // İşlem notları

    public TransactionDto()
    {
    }
}