using System.Net;
using System.Text.Json;
using Application.DTOs.Common;
using FluentValidation;

namespace API.Middlewares;

/// <summary>
/// Uygulama genelindeki yakalanmayan istisnaları yöneten middleware.
/// Hataları loglar ve istemciye standart bir JSON formatında hata yanıtı döner.
/// </summary>
public class ErrorHandlerMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ErrorHandlerMiddleware> _logger;
    private readonly IHostEnvironment _env; // Geliştirme ortamı kontrolü için

    public ErrorHandlerMiddleware(RequestDelegate next, ILogger<ErrorHandlerMiddleware> logger, IHostEnvironment env)
    {
        _next = next;
        _logger = logger;
        _env = env;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            // Sonraki middleware'i çağır
            await _next(context);
        }
        catch (Exception ex)
        {
            // Hata oluştuğunda yakala ve işle
            _logger.LogError(ex, "Beklenmedik bir hata oluştu: {ErrorMessage}", ex.Message);

            var response = context.Response;
            response.ContentType = "application/json";

            // Hata tipine göre durum kodu ve yanıtı belirle
            var errorResponse = new ErrorResponseDto(); // Standart hata yanıtı DTO'su

            switch (ex)
            {
                case ValidationException validationException:
                    // FluentValidation hataları
                    response.StatusCode = (int)HttpStatusCode.BadRequest; // 400
                    errorResponse.Title = "Validasyon Hatası";
                    errorResponse.Errors = validationException.Errors.Select(e => e.ErrorMessage).ToList();
                    break;

                // Buraya kendi özel istisna tipleriniz için case'ler ekleyebilirsiniz
                // case CustomNotFoundException notFoundEx:
                //     response.StatusCode = (int)HttpStatusCode.NotFound; // 404
                //     errorResponse.Title = "Kaynak Bulunamadı";
                //     errorResponse.Errors.Add(notFoundEx.Message);
                //     break;

                default:
                    // Diğer tüm beklenmedik hatalar
                    response.StatusCode = (int)HttpStatusCode.InternalServerError; // 500
                    errorResponse.Title = "Sunucu Hatası";
                    // Production ortamında detaylı hata mesajını gösterme!
                    errorResponse.Errors.Add(_env.IsDevelopment() ? ex.Message : "Beklenmedik bir sunucu hatası oluştu.");
                    // Geliştirme ortamında stack trace'i de ekleyebiliriz (opsiyonel)
                    if (_env.IsDevelopment())
                    {
                        errorResponse.Detail = ex.StackTrace;
                    }

                    break;
            }

            // JSON yanıtını oluştur
            var result = JsonSerializer.Serialize(errorResponse, new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase // camelCase formatında JSON
            });

            await response.WriteAsync(result);
        }
    }
}