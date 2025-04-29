using Application.DTOs.Transaction;
using Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

/// <summary>
/// İşlem (Gelir/Gider) işlemleri için API controller.
/// </summary>
[Authorize]
public class TransactionsController : BaseApiController
{
    private readonly ITransactionService _transactionService;

    public TransactionsController(ITransactionService transactionService)
    {
        _transactionService = transactionService;
    }

    /// <summary>
    /// Giriş yapmış kullanıcının işlemlerini filtreleyerek listeler.
    /// Filtre parametreleri query string üzerinden alınır.
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<TransactionDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetUserTransactions([FromQuery] TransactionFilterDto filterDto) // Query string'den alır
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _transactionService.GetUserTransactionsFilteredAsync(userId.Value, filterDto);
        return HandleResult(result);
    }

    /// <summary>
    /// Belirli bir işlemi ID ile getirir.
    /// </summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(TransactionDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetTransactionById(int id)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _transactionService.GetTransactionByIdAsync(userId.Value, id);
        return HandleResult(result);
    }

    /// <summary>
    /// Yeni bir işlem oluşturur.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(TransactionDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateTransaction([FromBody] CreateTransactionDto createTransactionDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _transactionService.CreateTransactionAsync(userId.Value, createTransactionDto);
        return HandleCreatedResult(result, nameof(GetTransactionById), new { id = result.Value?.Id });
    }

    /// <summary>
    /// Mevcut bir işlemi günceller.
    /// </summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> UpdateTransaction(int id, [FromBody] UpdateTransactionDto updateTransactionDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _transactionService.UpdateTransactionAsync(userId.Value, id, updateTransactionDto);
        return HandleResult(result);
    }

    /// <summary>
    /// Belirli bir işlemi siler (Soft Delete).
    /// </summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> DeleteTransaction(int id)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _transactionService.DeleteTransactionAsync(userId.Value, id);
        return HandleResult(result);
    }
}