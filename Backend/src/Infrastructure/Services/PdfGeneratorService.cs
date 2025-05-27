using Application.DTOs.Reports;
using Application.Interfaces.Services;
using System.Text;

namespace Infrastructure.Services;

/// <summary>
/// PDF rapor oluşturma servisi implementasyonu
/// </summary>
public class PdfGeneratorService : IPdfGeneratorService
{
    /// <summary>
    /// Rapor verilerinden PDF oluşturur
    /// </summary>
    public async Task<byte[]> GeneratePdfAsync(ReportDataDto reportData)
    {
        return reportData.Report.Type switch
        {
            Core.Enums.ReportType.IncomeExpenseAnalysis => await GenerateIncomeExpenseAnalysisPdfAsync(reportData),
            Core.Enums.ReportType.BudgetPerformance => await GenerateBudgetPerformancePdfAsync(reportData),
            Core.Enums.ReportType.CategoryAnalysis => await GenerateCategoryAnalysisPdfAsync(reportData),
            Core.Enums.ReportType.AccountSummary => await GenerateAccountSummaryPdfAsync(reportData),
            _ => await GenerateGenericPdfAsync(reportData)
        };
    }

    /// <summary>
    /// Gelir-Gider analizi PDF'i oluşturur
    /// </summary>
    public async Task<byte[]> GenerateIncomeExpenseAnalysisPdfAsync(ReportDataDto reportData)
    {
        var content = await Task.Run(() => CreatePdfContent("Gelir-Gider Analizi", reportData));
        return Encoding.UTF8.GetBytes(content);
    }

    /// <summary>
    /// Bütçe performans PDF'i oluşturur
    /// </summary>
    public async Task<byte[]> GenerateBudgetPerformancePdfAsync(ReportDataDto reportData)
    {
        var content = await Task.Run(() => CreatePdfContent("Bütçe Performansı", reportData));
        return Encoding.UTF8.GetBytes(content);
    }

    /// <summary>
    /// Kategori analizi PDF'i oluşturur
    /// </summary>
    public async Task<byte[]> GenerateCategoryAnalysisPdfAsync(ReportDataDto reportData)
    {
        var content = await Task.Run(() => CreatePdfContent("Kategori Analizi", reportData));
        return Encoding.UTF8.GetBytes(content);
    }

    /// <summary>
    /// Hesap özeti PDF'i oluşturur
    /// </summary>
    public async Task<byte[]> GenerateAccountSummaryPdfAsync(ReportDataDto reportData)
    {
        var content = await Task.Run(() => CreatePdfContent("Hesap Özeti", reportData));
        return Encoding.UTF8.GetBytes(content);
    }

    /// <summary>
    /// Genel PDF oluşturur
    /// </summary>
    private async Task<byte[]> GenerateGenericPdfAsync(ReportDataDto reportData)
    {
        var content = await Task.Run(() => CreatePdfContent(reportData.Report.Title, reportData));
        return Encoding.UTF8.GetBytes(content);
    }

    /// <summary>
    /// PDF içeriği oluşturur (Mock implementasyon)
    /// TODO: Gerçek PDF kütüphanesi ile değiştirilecek (örn: iTextSharp, PdfSharp)
    /// </summary>
    private string CreatePdfContent(string title, ReportDataDto reportData)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"RAPOR: {title}");
        sb.AppendLine($"Tarih: {reportData.Report.StartDate:dd/MM/yyyy} - {reportData.Report.EndDate:dd/MM/yyyy}");
        sb.AppendLine($"Oluşturma Tarihi: {reportData.Report.GeneratedAt:dd/MM/yyyy HH:mm}");
        sb.AppendLine("".PadRight(50, '='));
        sb.AppendLine();

        // Finansal özet
        sb.AppendLine("FİNANSAL ÖZET");
        sb.AppendLine("".PadRight(20, '-'));
        sb.AppendLine($"Toplam Gelir: {reportData.Summary.TotalIncome:C}");
        sb.AppendLine($"Toplam Gider: {reportData.Summary.TotalExpense:C}");
        sb.AppendLine($"Net Tutar: {reportData.Summary.NetAmount:C}");
        sb.AppendLine($"Toplam Bütçe: {reportData.Summary.TotalBudget:C}");
        sb.AppendLine($"Bütçe Kullanım Oranı: %{reportData.Summary.BudgetUtilization:F1}");
        sb.AppendLine($"İşlem Sayısı: {reportData.Summary.TransactionCount}");
        sb.AppendLine();

        // Kategori analizi
        if (reportData.CategoryAnalysis.Any())
        {
            sb.AppendLine("KATEGORİ ANALİZİ");
            sb.AppendLine("".PadRight(20, '-'));
            foreach (var category in reportData.CategoryAnalysis)
            {
                sb.AppendLine($"{category.CategoryName}: {category.Amount:C} (%{category.Percentage:F1})");
            }
            sb.AppendLine();
        }

        // Hesap özetleri
        if (reportData.AccountSummaries.Any())
        {
            sb.AppendLine("HESAP ÖZETLERİ");
            sb.AppendLine("".PadRight(20, '-'));
            foreach (var account in reportData.AccountSummaries)
            {
                sb.AppendLine($"{account.AccountName}: {account.CurrentBalance:C}");
            }
            sb.AppendLine();
        }

        return sb.ToString();
    }
} 