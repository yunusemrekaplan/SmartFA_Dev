using Application.DTOs.Account;
using Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

/// <summary>
/// Hesap işlemleri için API controller.
/// </summary>
[Authorize] // Bu controller'daki tüm action'lar yetkilendirme gerektirir.
public class AccountsController : BaseApiController // BaseApiController'dan miras alır
{
    private readonly IAccountService _accountService;

    public AccountsController(IAccountService accountService)
    {
        _accountService = accountService;
    }

    /// <summary>
    /// Giriş yapmış kullanıcının tüm hesaplarını listeler.
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<AccountDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetUserAccounts()
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği."); // Token'dan ID alınamazsa

        var result = await _accountService.GetUserAccountsAsync(userId.Value);
        return HandleResult(result); // BaseApiController'daki yardımcı metot
    }

    /// <summary>
    /// Belirli bir hesabı ID ile getirir.
    /// </summary>
    [HttpGet("{id:int}")] // Route constraint: id integer olmalı
    [ProducesResponseType(typeof(AccountDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetAccountById(int id)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _accountService.GetAccountByIdAsync(userId.Value, id);
        return HandleResult(result); // BaseApiController'daki yardımcı metot
    }

    /// <summary>
    /// Yeni bir hesap oluşturur.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(AccountDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateAccount([FromBody] CreateAccountDto createAccountDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _accountService.CreateAccountAsync(userId.Value, createAccountDto);

        // BaseApiController'daki yardımcı metot ile 201 Created yanıtı döndür
        return HandleCreatedResult(result, nameof(GetAccountById), new { id = result.Value?.Id });
    }

    /// <summary>
    /// Mevcut bir hesabı günceller.
    /// </summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> UpdateAccount(int id, [FromBody] UpdateAccountDto updateAccountDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _accountService.UpdateAccountAsync(userId.Value, id, updateAccountDto);
        return HandleResult(result); // BaseApiController'daki yardımcı metot
    }

    /// <summary>
    /// Belirli bir hesabı siler (Soft Delete).
    /// </summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)] // İlişkili veri varsa vb.
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> DeleteAccount(int id)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _accountService.DeleteAccountAsync(userId.Value, id);
        return HandleResult(result); // BaseApiController'daki yardımcı metot
    }
}