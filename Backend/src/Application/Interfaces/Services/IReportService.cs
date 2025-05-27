using Application.DTOs.Reports;
using Application.Wrappers;
using Core.Enums;

namespace Application.Interfaces.Services;

/// <summary>
/// Bu arayüz, rapor oluşturma ve rapor verilerini yönetme işlemlerini tanımlar.
/// </summary>
public interface IReportService
{
    /// <summary>
    /// Belirli bir kullanıcının rapor oluşturmasını sağlar.
    /// </summary>
    Task<Result<ReportDataDto>> GenerateReportAsync(int userId, CreateReportRequestDto request);
    
    /// <summary>
    /// Belirli bir kullanıcının raporlarını sayfalandırarak getirir.
    /// </summary>
    Task<Result<List<ReportDto>>> GetUserReportsAsync(int userId, int page = 1, int pageSize = 10);
    
    /// <summary>
    /// Belirli bir kullanıcının raporunu ID ile getirir.
    /// </summary>
    Task<Result<ReportDataDto>> GetReportByIdAsync(int userId, int reportId);
    
    /// <summary>
    /// Belirli bir kullanıcının raporunu günceller.
    /// </summary>
    Task<Result<bool>> DeleteReportAsync(int userId, int reportId);
    
    /// <summary>
    /// Belirli bir kullanıcının raporunu dışa aktarır.
    /// </summary>
    Task<Result<byte[]>> ExportReportAsync(int userId, int reportId, ReportFormat format);
    
    /// <summary>
    /// Belirli bir kullanıcının hızlı raporunu oluşturur.
    /// </summary>
    Task<Result<ReportDataDto>> GetQuickReportAsync(int userId, ReportType type, ReportPeriod period);
}