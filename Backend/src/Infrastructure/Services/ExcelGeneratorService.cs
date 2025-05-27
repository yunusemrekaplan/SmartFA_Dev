using Application.DTOs.Reports;
using Application.Interfaces.Services;
using System.Text;

namespace Infrastructure.Services;

/// <summary>
/// Excel rapor oluşturma servisi implementasyonu
/// </summary>
public class ExcelGeneratorService : IExcelGeneratorService
{
    /// <summary>
    /// Rapor verilerinden Excel oluşturur
    /// </summary>
    public async Task<byte[]> GenerateExcelAsync(ReportDataDto reportData)
    {
        return reportData.Report.Type switch
        {
            Core.Enums.ReportType.IncomeExpenseAnalysis => await GenerateIncomeExpenseAnalysisExcelAsync(reportData),
            Core.Enums.ReportType.BudgetPerformance => await GenerateBudgetPerformanceExcelAsync(reportData),
            Core.Enums.ReportType.CategoryAnalysis => await GenerateCategoryAnalysisExcelAsync(reportData),
            Core.Enums.ReportType.AccountSummary => await GenerateAccountSummaryExcelAsync(reportData),
            _ => await GenerateGenericExcelAsync(reportData)
        };
    }

    /// <summary>
    /// Gelir-Gider analizi Excel'i oluşturur
    /// </summary>
    public async Task<byte[]> GenerateIncomeExpenseAnalysisExcelAsync(ReportDataDto reportData)
    {
        var content = await Task.Run(() => CreateExcelContent("Gelir-Gider Analizi", reportData));
        return Encoding.UTF8.GetBytes(content);
    }

    /// <summary>
    /// Bütçe performans Excel'i oluşturur
    /// </summary>
    public async Task<byte[]> GenerateBudgetPerformanceExcelAsync(ReportDataDto reportData)
    {
        var content = await Task.Run(() => CreateExcelContent("Bütçe Performansı", reportData));
        return Encoding.UTF8.GetBytes(content);
    }

    /// <summary>
    /// Kategori analizi Excel'i oluşturur
    /// </summary>
    public async Task<byte[]> GenerateCategoryAnalysisExcelAsync(ReportDataDto reportData)
    {
        var content = await Task.Run(() => CreateExcelContent("Kategori Analizi", reportData));
        return Encoding.UTF8.GetBytes(content);
    }

    /// <summary>
    /// Hesap özeti Excel'i oluşturur
    /// </summary>
    public async Task<byte[]> GenerateAccountSummaryExcelAsync(ReportDataDto reportData)
    {
        var content = await Task.Run(() => CreateExcelContent("Hesap Özeti", reportData));
        return Encoding.UTF8.GetBytes(content);
    }

    /// <summary>
    /// İşlem verilerini CSV formatında oluşturur
    /// </summary>
    public async Task<byte[]> GenerateCsvAsync(ReportDataDto reportData)
    {
        var sb = new StringBuilder();
        
        // CSV Headers
        sb.AppendLine("Kategori,Tutar,Yüzde,İşlem Sayısı");
        
        // CSV Data
        foreach (var category in reportData.CategoryAnalysis)
        {
            sb.AppendLine($"{category.CategoryName},{category.Amount},{category.Percentage:F1},{category.TransactionCount}");
        }

        return Encoding.UTF8.GetBytes(sb.ToString());
    }

    /// <summary>
    /// Genel Excel oluşturur
    /// </summary>
    private async Task<byte[]> GenerateGenericExcelAsync(ReportDataDto reportData)
    {
        var content = await Task.Run(() => CreateExcelContent(reportData.Report.Title, reportData));
        return Encoding.UTF8.GetBytes(content);
    }

    /// <summary>
    /// Excel içeriği oluşturur (Mock implementasyon)
    /// TODO: Gerçek Excel kütüphanesi ile değiştirilecek (örn: EPPlus, ClosedXML)
    /// </summary>
    private string CreateExcelContent(string title, ReportDataDto reportData)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"RAPOR: {title}");
        sb.AppendLine($"Tarih: {reportData.Report.StartDate:dd/MM/yyyy} - {reportData.Report.EndDate:dd/MM/yyyy}");
        sb.AppendLine($"Oluşturma Tarihi: {reportData.Report.GeneratedAt:dd/MM/yyyy HH:mm}");
        sb.AppendLine();

        // Finansal özet tablosu
        sb.AppendLine("FİNANSAL ÖZET");
        sb.AppendLine("Metrik\tDeğer");
        sb.AppendLine($"Toplam Gelir\t{reportData.Summary.TotalIncome:C}");
        sb.AppendLine($"Toplam Gider\t{reportData.Summary.TotalExpense:C}");
        sb.AppendLine($"Net Tutar\t{reportData.Summary.NetAmount:C}");
        sb.AppendLine($"Toplam Bütçe\t{reportData.Summary.TotalBudget:C}");
        sb.AppendLine($"Bütçe Kullanım Oranı\t%{reportData.Summary.BudgetUtilization:F1}");
        sb.AppendLine($"İşlem Sayısı\t{reportData.Summary.TransactionCount}");
        sb.AppendLine();

        // Kategori analizi tablosu
        if (reportData.CategoryAnalysis.Any())
        {
            sb.AppendLine("KATEGORİ ANALİZİ");
            sb.AppendLine("Kategori\tTür\tTutar\tYüzde\tİşlem Sayısı\tBütçe");
            foreach (var category in reportData.CategoryAnalysis)
            {
                sb.AppendLine($"{category.CategoryName}\t{category.CategoryType}\t{category.Amount:C}\t%{category.Percentage:F1}\t{category.TransactionCount}\t{category.BudgetAmount:C}");
            }
            sb.AppendLine();
        }

        // Hesap özetleri tablosu
        if (reportData.AccountSummaries.Any())
        {
            sb.AppendLine("HESAP ÖZETLERİ");
            sb.AppendLine("Hesap\tTür\tBaşlangıç Bakiye\tMevcut Bakiye\tGelir\tGider\tİşlem Sayısı");
            foreach (var account in reportData.AccountSummaries)
            {
                sb.AppendLine($"{account.AccountName}\t{account.AccountType}\t{account.InitialBalance:C}\t{account.CurrentBalance:C}\t{account.TotalIncome:C}\t{account.TotalExpense:C}\t{account.TransactionCount}");
            }
            sb.AppendLine();
        }

        return sb.ToString();
    }
} 