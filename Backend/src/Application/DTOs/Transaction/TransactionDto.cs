using Core.Enums;

namespace Application.DTOs.Transaction;

/// <summary>
/// İşlem bilgilerini temsil eden DTO (Listeleme ve Detay).
/// </summary>
public record TransactionDto(
    int Id,
    int AccountId,
    string AccountName, // İlişkili hesap adı
    int CategoryId,
    string CategoryName, // İlişkili kategori adı
    string? CategoryIcon, // İlişkili kategori ikonu
    CategoryType CategoryType, // İlişkili kategori tipi
    decimal Amount,
    DateTime TransactionDate,
    string? Notes
);