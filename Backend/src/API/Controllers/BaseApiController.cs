using System.Security.Claims;
using Application.Wrappers;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

/// <summary>
/// Tüm API controller'ları için temel sınıf.
/// Ortak işlevleri barındırır (örn: Kullanıcı ID'si alma, Sonuç işleme).
/// </summary>
[ApiController]
[Route("api/[controller]")] // api/controlleradi şeklinde route oluşturur
public abstract class BaseApiController : ControllerBase
{
    /// <summary>
    /// Geçerli JWT token'ından kullanıcı ID'sini alır.
    /// [Authorize] attribute'u ile korunan metotlarda kullanılır.
    /// </summary>
    /// <returns>Kullanıcı ID'si veya bulunamazsa null</returns>
    protected int? GetUserIdFromToken()
    {
        // HttpContext.User.FindFirst(ClaimTypes.NameIdentifier) veya özel claim adı ("sub") kullanılabilir.
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");

        if (int.TryParse(userIdClaim, out int userId))
        {
            return userId;
        }

        // Kullanıcı ID'si bulunamazsa veya parse edilemezse null döndür.
        // Çağıran metot null kontrolü yapmalı ve Unauthorized döndürmeli.
        return null;
    }

    /// <summary>
    /// Servislerden dönen Result nesnesini uygun IActionResult'a dönüştürür.
    /// </summary>
    protected IActionResult HandleResult<T>(Result<T> result)
    {
        if (result.IsSuccess && result.Value != null)
            return Ok(result.Value); // 200 OK

        // Başarılı ama değer yoksa (örn: GetById bulunamadı) NotFound döndür.
        if (result.IsSuccess && result.Value == null)
            return NotFound(); // 404 Not Found

        // Hata durumları
        // Servis katmanında hata tiplerine göre ayrım yapılıp Result'a eklenebilir
        // ve burada ona göre farklı durum kodları (400, 404, 409 vb.) döndürülebilir.
        // Şimdilik genel bir BadRequest varsayalım.
        // Eğer spesifik bir hata mesajı NotFound içeriyorsa 404 döndür.
        if (!result.IsSuccess && result.Errors.Any(e => e.Contains("bulunamadı", StringComparison.OrdinalIgnoreCase)))
            return NotFound(new { Errors = result.Errors }); // 404 Not Found

        // Diğer tüm hatalar için BadRequest
        return BadRequest(new { Errors = result.Errors }); // 400 Bad Request
    }

    /// <summary>
    /// Servislerden dönen Result (veri içermeyen) nesnesini uygun IActionResult'a dönüştürür.
    /// </summary>
    protected IActionResult HandleResult(Result result)
    {
        if (result.IsSuccess)
            return NoContent(); // PUT, DELETE, POST (veri döndürmeyen) için 204 No Content

        // Hata durumları (NotFound kontrolü eklendi)
        if (!result.IsSuccess && result.Errors.Any(e => e.Contains("bulunamadı", StringComparison.OrdinalIgnoreCase)))
            return NotFound(new { Errors = result.Errors }); // 404 Not Found

        return BadRequest(new { Errors = result.Errors }); // 400 Bad Request
    }

    /// <summary>
    /// Özellikle Created (201) yanıtı için kullanılır.
    /// </summary>
    protected IActionResult HandleCreatedResult<T>(Result<T> result, string actionName, object? routeValues = null)
    {
        if (result.IsSuccess && result.Value != null)
            // CreatedAtAction ilgili kaynağa GET isteği yapılabilecek URI'yi döndürür.
            return CreatedAtAction(actionName, routeValues, result.Value); // 201 Created

        // Hata durumları
        return BadRequest(new { Errors = result.Errors }); // 400 Bad Request
    }
}