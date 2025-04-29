using Application.DTOs.Budget;
using Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

/// <summary>
/// Bütçe işlemleri için API controller.
/// </summary>
[Authorize]
public class BudgetsController : BaseApiController
{
    private readonly IBudgetService _budgetService;

    public BudgetsController(IBudgetService budgetService)
    {
        _budgetService = budgetService;
    }

    /// <summary>
    /// Belirli bir dönemdeki bütçeleri listeler.
    /// </summary>
    /// <param name="year">Yıl</param>
    /// <param name="month">Ay (1-12)</param>
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<BudgetDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)] // Geçersiz ay/yıl için
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetBudgetsByPeriod([FromQuery] int year, [FromQuery] int month)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        if (month < 1 || month > 12 || year < 2000 || year > 2100) // Basit validasyon
            return BadRequest("Geçersiz ay veya yıl.");

        var result = await _budgetService.GetUserBudgetsByPeriodAsync(userId.Value, month, year);
        return HandleResult(result);
    }

    /// <summary>
    /// Yeni bir bütçe oluşturur.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(BudgetDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateBudget([FromBody] CreateBudgetDto createBudgetDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        if (createBudgetDto.Month < 1 || createBudgetDto.Month > 12 || createBudgetDto.Year < 2000 || createBudgetDto.Year > 2100)
            return BadRequest("Geçersiz ay veya yıl.");

        var result = await _budgetService.CreateBudgetAsync(userId.Value, createBudgetDto);

        // GetBudgetById action'ı olmadığı için manuel URI
        if (result.IsSuccess && result.Value != null)
            return Created($"/api/budgets/{result.Value.Id}", result.Value);

        return HandleResult(result);
    }

    /// <summary>
    /// Mevcut bir bütçeyi günceller (Sadece tutar).
    /// </summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> UpdateBudget(int id, [FromBody] UpdateBudgetDto updateBudgetDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _budgetService.UpdateBudgetAsync(userId.Value, id, updateBudgetDto);
        return HandleResult(result);
    }

    /// <summary>
    /// Belirli bir bütçeyi siler (Soft Delete).
    /// </summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> DeleteBudget(int id)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _budgetService.DeleteBudgetAsync(userId.Value, id);
        return HandleResult(result);
    }
}