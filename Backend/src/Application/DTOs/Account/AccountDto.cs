namespace Application.DTOs.Account;

/// <summary>
/// Hesap bilgilerini temsil eden DTO (Listeleme ve Detay).
/// </summary>
public record AccountDto(
    int Id,
    string Name,
    string Type, // Enum yerine string olarak gösterim
    string Currency,
    decimal CurrentBalance // Hesaplanan güncel bakiye
);