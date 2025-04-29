using Application.DTOs.Category;
using Application.Interfaces.Services;
using Core.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

/// <summary>
/// Kategori işlemleri için API controller.
/// </summary>
[Authorize]
public class CategoriesController : BaseApiController
{
    private readonly ICategoryService _categoryService;

    public CategoriesController(ICategoryService categoryService)
    {
        _categoryService = categoryService;
    }

    /// <summary>
    /// Kullanıcının ve ön tanımlı kategorileri tipe göre listeler.
    /// </summary>
    /// <param name="type">Kategori tipi (Gider veya Gelir)</param>
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<CategoryDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetCategories([FromQuery] CategoryType type) // Gider=0, Gelir=1
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _categoryService.GetUserAndPredefinedCategoriesAsync(userId.Value, type);
        return HandleResult(result);
    }

    /// <summary>
    /// Yeni bir özel kategori oluşturur.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(CategoryDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateCategory([FromBody] CreateCategoryDto createCategoryDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _categoryService.CreateCategoryAsync(userId.Value, createCategoryDto);
        // Yeni kategori için GetById action'ı olmadığı için CreatedAtAction kullanmıyoruz.
        if (result.IsSuccess && result.Value != null)
            // Kategori için GetById endpoint'i olmadığı varsayıldı, basit Created döndürülüyor.
            // İdealde, GetCategoryById gibi bir endpoint olsaydı CreatedAtAction kullanılabilirdi.
            return Created($"/api/categories/{result.Value.Id}", result.Value);

        return HandleResult(result); // Hata durumları için
    }

    /// <summary>
    /// Mevcut bir özel kategoriyi günceller.
    /// </summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> UpdateCategory(int id, [FromBody] UpdateCategoryDto updateCategoryDto)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _categoryService.UpdateCategoryAsync(userId.Value, id, updateCategoryDto);
        return HandleResult(result);
    }

    /// <summary>
    /// Belirli bir özel kategoriyi siler (Soft Delete).
    /// </summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)] // İlişkili veri varsa
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> DeleteCategory(int id)
    {
        var userId = GetUserIdFromToken();
        if (!userId.HasValue) return Unauthorized("Geçersiz kullanıcı kimliği.");

        var result = await _categoryService.DeleteCategoryAsync(userId.Value, id);
        return HandleResult(result);
    }
}