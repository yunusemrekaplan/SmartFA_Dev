using Application.DTOs.Debt;
using Application.DTOs.DebtPayment;
using Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

/// <summary>
/// Borç ve borç ödeme işlemleri için API controller.
/// </summary>
[Authorize]
public class DebtsController : BaseApiController
{
    private readonly IDebtService _debtService;

    public DebtsController(IDebtService debtService)
    {
        _debtService = debtService;
    }

    /// <summary>
    /// Kullanıcının aktif borçlarını listeler.
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<DebtDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetActiveDebts()
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _debtService.GetUserActiveDebtsAsync(userId.Value);
        return HandleResult(result);
    }

    /// <summary>
    /// Belirli bir borcu ID ile getirir.
    /// </summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(DebtDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetDebtById(int id)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _debtService.GetDebtByIdAsync(userId.Value, id);
        return HandleResult(result);
    }

    /// <summary>
    /// Yeni bir borç oluşturur.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(DebtDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateDebt([FromBody] CreateDebtDto createDebtDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _debtService.CreateDebtAsync(userId.Value, createDebtDto);
        return HandleCreatedResult(result, nameof(GetDebtById), new { id = result.Value?.Id });
    }

    /// <summary>
    /// Mevcut bir borcu günceller (Ad, Alacaklı).
    /// </summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> UpdateDebt(int id, [FromBody] UpdateDebtDto updateDebtDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _debtService.UpdateDebtAsync(userId.Value, id, updateDebtDto);
        return HandleResult(result);
    }

    /// <summary>
    /// Belirli bir borcu siler (Soft Delete).
    /// </summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)] // İlişkili ödeme varsa
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> DeleteDebt(int id)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _debtService.DeleteDebtAsync(userId.Value, id);
        return HandleResult(result);
    }

    // --- Borç Ödemeleri için Alt Kaynak ---

    /// <summary>
    /// Belirli bir borca yeni bir ödeme ekler.
    /// </summary>
    [HttpPost("{debtId:int}/payments")] // Route: /api/debts/{debtId}/payments
    [ProducesResponseType(typeof(DebtPaymentDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)] // Borç bulunamazsa
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> AddDebtPayment(int debtId, [FromBody] CreateDebtPaymentDto createDebtPaymentDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        // Gelen DTO'nun debtId'si ile route'daki debtId eşleşmeli (güvenlik)
        if (debtId != createDebtPaymentDto.DebtId)
        {
            return BadRequest("Route ID ve ödeme bilgisi ID'si eşleşmiyor.");
        }

        var result = await _debtService.AddDebtPaymentAsync(userId.Value, createDebtPaymentDto);

        // Başarılı ödeme için 201 Created döndür (GetDebtPayments action'ı olmadığı için manuel URI)
        if (result.IsSuccess && result.Value != null)
            // Ödemenin kendi ID'si ile URI oluşturmak daha doğru olabilir.
            return Created($"/api/debts/{debtId}/payments/{result.Value.Id}", result.Value);

        return HandleResult(result); // Hata durumları (NotFound dahil)
    }

    /// <summary>
    /// Belirli bir borcun tüm ödemelerini listeler.
    /// </summary>
    [HttpGet("{debtId:int}/payments")] // Route: /api/debts/{debtId}/payments
    [ProducesResponseType(typeof(IReadOnlyList<DebtPaymentDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)] // Borç bulunamazsa
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetDebtPayments(int debtId)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _debtService.GetDebtPaymentsAsync(userId.Value, debtId);
        return HandleResult(result);
    }

    // Ödeme silme/güncelleme endpoint'leri de eklenebilir:
    // DELETE /api/debts/{debtId}/payments/{paymentId}
    // PUT /api/debts/{debtId}/payments/{paymentId}
}