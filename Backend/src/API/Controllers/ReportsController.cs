using Application.DTOs.Reports;
using Application.Interfaces.Services;
using Core.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

/// <summary>
/// Raporlama işlemleri için API controller'ı
/// </summary>
[Authorize]
[Route("api/[controller]")]
public class ReportsController : BaseApiController
{
    private readonly IReportService _reportService;

    public ReportsController(IReportService reportService)
    {
        _reportService = reportService;
    }

    /// <summary>
    /// Yeni rapor oluşturur
    /// </summary>
    /// <param name="request">Rapor oluşturma isteği</param>
    /// <returns>Oluşturulan rapor verisi</returns>
    [HttpPost]
    public async Task<IActionResult> CreateReport([FromBody] CreateReportRequestDto request)
    {
        var userId = GetUserIdFromToken() ?? throw new UnauthorizedAccessException("Kullanıcı kimliği bulunamadı");
        var result = await _reportService.GenerateReportAsync(userId, request);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return BadRequest(result);
    }

    /// <summary>
    /// Kullanıcının raporlarını getirir
    /// </summary>
    /// <param name="page">Sayfa numarası</param>
    /// <param name="pageSize">Sayfa boyutu</param>
    /// <returns>Rapor listesi</returns>
    [HttpGet]
    public async Task<IActionResult> GetReports([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var userId = GetUserIdFromToken() ?? throw new UnauthorizedAccessException("Kullanıcı kimliği bulunamadı");
        var result = await _reportService.GetUserReportsAsync(userId, page, pageSize);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return BadRequest(result);
    }

    /// <summary>
    /// Belirli bir raporu getirir
    /// </summary>
    /// <param name="id">Rapor ID'si</param>
    /// <returns>Rapor verisi</returns>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetReport(int id)
    {
        var userId = GetUserIdFromToken() ?? throw new UnauthorizedAccessException("Kullanıcı kimliği bulunamadı");
        var result = await _reportService.GetReportByIdAsync(userId, id);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return BadRequest(result);
    }

    /// <summary>
    /// Rapor siler
    /// </summary>
    /// <param name="id">Rapor ID'si</param>
    /// <returns>Silme sonucu</returns>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteReport(int id)
    {
        var userId = GetUserIdFromToken() ?? throw new UnauthorizedAccessException("Kullanıcı kimliği bulunamadı");
        var result = await _reportService.DeleteReportAsync(userId, id);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return BadRequest(result);
    }

    /// <summary>
    /// Raporu dışa aktarır
    /// </summary>
    /// <param name="id">Rapor ID'si</param>
    /// <param name="format">Dışa aktarma formatı</param>
    /// <returns>Dosya</returns>
    [HttpGet("{id}/export")]
    public async Task<IActionResult> ExportReport(int id, [FromQuery] ReportFormat format = ReportFormat.PDF)
    {
        var userId = GetUserIdFromToken() ?? throw new UnauthorizedAccessException("Kullanıcı kimliği bulunamadı");
        var result = await _reportService.ExportReportAsync(userId, id, format);

        if (result.IsSuccess)
        {
            var contentType = format switch
            {
                ReportFormat.PDF => "application/pdf",
                ReportFormat.Excel => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                ReportFormat.CSV => "text/csv",
                _ => "application/octet-stream"
            };

            var fileName = format switch
            {
                ReportFormat.PDF => $"rapor_{id}.pdf",
                ReportFormat.Excel => $"rapor_{id}.xlsx",
                ReportFormat.CSV => $"rapor_{id}.csv",
                _ => $"rapor_{id}"
            };

            if (result.Value == null)
            {
                return BadRequest("Rapor verileri bulunamadı");
            }

            return File(result.Value, contentType, fileName);
        }

        return BadRequest(result);
    }

    /// <summary>
    /// Hızlı rapor oluşturur
    /// </summary>
    /// <param name="type">Rapor türü</param>
    /// <param name="period">Rapor dönemi</param>
    /// <returns>Hızlı rapor verisi</returns>
    [HttpGet("quick")]
    public async Task<IActionResult> GetQuickReport(
        [FromQuery] ReportType type = ReportType.IncomeExpenseAnalysis,
        [FromQuery] ReportPeriod period = ReportPeriod.Monthly)
    {
        var userId = GetUserIdFromToken() ?? throw new UnauthorizedAccessException("Kullanıcı kimliği bulunamadı");
        var result = await _reportService.GetQuickReportAsync(userId, type, period);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return BadRequest(result);
    }

    /// <summary>
    /// Rapor türlerini getirir
    /// </summary>
    /// <returns>Rapor türleri listesi</returns>
    [HttpGet("types")]
    public IActionResult GetReportTypes()
    {
        var reportTypes = Enum.GetValues<ReportType>()
            .Select(rt => new
            {
                Value = (int)rt,
                Name = rt.ToString(),
                DisplayName = GetReportTypeDisplayName(rt)
            })
            .ToList();

        return Ok(reportTypes);
    }

    /// <summary>
    /// Rapor dönemlerini getirir
    /// </summary>
    /// <returns>Rapor dönemleri listesi</returns>
    [HttpGet("periods")]
    public IActionResult GetReportPeriods()
    {
        var reportPeriods = Enum.GetValues<ReportPeriod>()
            .Select(rp => new
            {
                Value = (int)rp,
                Name = rp.ToString(),
                DisplayName = GetReportPeriodDisplayName(rp)
            })
            .ToList();

        return Ok(reportPeriods);
    }

    /// <summary>
    /// Rapor formatlarını getirir
    /// </summary>
    /// <returns>Rapor formatları listesi</returns>
    [HttpGet("formats")]
    public IActionResult GetReportFormats()
    {
        var reportFormats = Enum.GetValues<ReportFormat>()
            .Select(rf => new
            {
                Value = (int)rf,
                Name = rf.ToString(),
                DisplayName = GetReportFormatDisplayName(rf)
            })
            .ToList();

        return Ok(reportFormats);
    }

    /// <summary>
    /// Rapor türü görüntü adını getirir
    /// </summary>
    private string GetReportTypeDisplayName(ReportType type) => type switch
    {
        ReportType.IncomeExpenseAnalysis => "Gelir-Gider Analizi",
        ReportType.BudgetPerformance => "Bütçe Performansı",
        ReportType.CategoryAnalysis => "Kategori Analizi",
        ReportType.AccountSummary => "Hesap Özeti",
        ReportType.CashFlowAnalysis => "Nakit Akış Analizi",
        ReportType.MonthlyFinancialSummary => "Aylık Finansal Özet",
        ReportType.YearlyFinancialSummary => "Yıllık Finansal Özet",
        ReportType.CustomReport => "Özel Rapor",
        _ => "Bilinmeyen Rapor"
    };

    /// <summary>
    /// Rapor dönem görüntü adını getirir
    /// </summary>
    private string GetReportPeriodDisplayName(ReportPeriod period) => period switch
    {
        ReportPeriod.Daily => "Günlük",
        ReportPeriod.Weekly => "Haftalık",
        ReportPeriod.Monthly => "Aylık",
        ReportPeriod.Quarterly => "Üç Aylık",
        ReportPeriod.Yearly => "Yıllık",
        ReportPeriod.Custom => "Özel Dönem",
        _ => "Bilinmeyen Dönem"
    };

    /// <summary>
    /// Rapor format görüntü adını getirir
    /// </summary>
    private string GetReportFormatDisplayName(ReportFormat format) => format switch
    {
        ReportFormat.PDF => "PDF",
        ReportFormat.Excel => "Excel",
        ReportFormat.JSON => "JSON",
        ReportFormat.CSV => "CSV",
        _ => "Bilinmeyen Format"
    };
} 