using Application.DTOs.Reports;

namespace Application.Interfaces.Services;

/// <summary>
/// Excel rapor oluşturma servisi interface'i
/// </summary>
public interface IExcelGeneratorService
{
    /// <summary>
    /// Rapor verilerinden Excel oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>Excel byte array</returns>
    Task<byte[]> GenerateExcelAsync(ReportDataDto reportData);

    /// <summary>
    /// Gelir-Gider analizi Excel'i oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>Excel byte array</returns>
    Task<byte[]> GenerateIncomeExpenseAnalysisExcelAsync(ReportDataDto reportData);

    /// <summary>
    /// Bütçe performans Excel'i oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>Excel byte array</returns>
    Task<byte[]> GenerateBudgetPerformanceExcelAsync(ReportDataDto reportData);

    /// <summary>
    /// Kategori analizi Excel'i oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>Excel byte array</returns>
    Task<byte[]> GenerateCategoryAnalysisExcelAsync(ReportDataDto reportData);

    /// <summary>
    /// Hesap özeti Excel'i oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>Excel byte array</returns>
    Task<byte[]> GenerateAccountSummaryExcelAsync(ReportDataDto reportData);

    /// <summary>
    /// İşlem verilerini CSV formatında oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>CSV byte array</returns>
    Task<byte[]> GenerateCsvAsync(ReportDataDto reportData);
} 