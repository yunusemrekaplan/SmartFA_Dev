using System.ComponentModel.DataAnnotations;
using Core.Enums;

namespace Application.DTOs.Account;

/// <summary>
/// Yeni hesap oluşturma isteği için DTO.
/// </summary>
public record CreateAccountDto(
    [Required] string Name,
    [Required] AccountType Type,
    [Required] string Currency,
    [Required] decimal InitialBalance
);