using Application.DTOs.Reports;

namespace Application.Interfaces.Services;

/// <summary>
/// PDF rapor oluşturma servisi interface'i
/// </summary>
public interface IPdfGeneratorService
{
    /// <summary>
    /// Rapor verilerinden PDF oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>PDF byte array</returns>
    Task<byte[]> GeneratePdfAsync(ReportDataDto reportData);

    /// <summary>
    /// Gelir-Gider analizi PDF'i oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>PDF byte array</returns>
    Task<byte[]> GenerateIncomeExpenseAnalysisPdfAsync(ReportDataDto reportData);

    /// <summary>
    /// Bütçe performans PDF'i oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>PDF byte array</returns>
    Task<byte[]> GenerateBudgetPerformancePdfAsync(ReportDataDto reportData);

    /// <summary>
    /// Kategori analizi PDF'i oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>PDF byte array</returns>
    Task<byte[]> GenerateCategoryAnalysisPdfAsync(ReportDataDto reportData);

    /// <summary>
    /// Hesap özeti PDF'i oluşturur
    /// </summary>
    /// <param name="reportData">Rapor verileri</param>
    /// <returns>PDF byte array</returns>
    Task<byte[]> GenerateAccountSummaryPdfAsync(ReportDataDto reportData);
} 