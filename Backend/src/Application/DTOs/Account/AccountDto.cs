using Core.Enums;

namespace Application.DTOs.Account;

/// <summary>
/// Hesap bilgilerini temsil eden DTO (Listeleme ve Detay).
/// </summary>
public record AccountDto
{
    public int Id { get; init; } // Hesap ID'si
    public string Name { get; init; } // Hesap adı
    public AccountType Type { get; init; } // Hesap türü (Enum)
    public string Currency { get; init; } // Para birimi
    public decimal CurrentBalance { get; init; } // Güncel bakiye

    public AccountDto()
    {
    } // Parametresiz yapıcı
}