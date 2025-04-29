namespace Application.DTOs.Common;

/// <summary>
/// Standart hata yanıtı için DTO.
/// </summary>
public class ErrorResponseDto
{
    public string Title { get; set; } = "Hata";
    public List<string> Errors { get; set; } = new List<string>();
    public string? Detail { get; set; } // Geliştirme ortamında StackTrace vb. için
}