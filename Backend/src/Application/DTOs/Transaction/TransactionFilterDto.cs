using Core.Enums;

namespace Application.DTOs.Transaction;

/// <summary>
/// İşlem listeleme için filtreleme kriterlerini içeren DTO.
/// </summary>
public record TransactionFilterDto(
    int? AccountId,
    int? CategoryId,
    DateTime? StartDate,
    DateTime? EndDate,
    CategoryType? Type, // Gelir/Gider filtresi
    int PageNumber = 1,
    int PageSize = 20,
    string SortCriteria = "Date" // Varsayılan sıralama kriteri
);