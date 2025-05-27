using Application.DTOs.Reports;
using Application.Interfaces;
using Application.Interfaces.Services;
using Application.Wrappers;
using AutoMapper;
using Core.Entities;
using Core.Enums;
using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace Application.Services;

/// <summary>
/// Rapor işlemlerini yöneten servis implementasyonu
/// </summary>
public class ReportService : IReportService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IPdfGeneratorService _pdfGeneratorService;
    private readonly IExcelGeneratorService _excelGeneratorService;
    private readonly IMapper _mapper;
    private readonly ILogger<ReportService> _logger;

    public ReportService(
        IUnitOfWork unitOfWork,
        IPdfGeneratorService pdfGeneratorService,
        IExcelGeneratorService excelGeneratorService,
        IMapper mapper,
        ILogger<ReportService> logger)
    {
        _unitOfWork = unitOfWork;
        _pdfGeneratorService = pdfGeneratorService;
        _excelGeneratorService = excelGeneratorService;
        _mapper = mapper;
        _logger = logger;
    }

    /// <summary>
    /// Yeni rapor oluşturur
    /// </summary>
    public async Task<Result<ReportDataDto>> GenerateReportAsync(int userId, CreateReportRequestDto request)
    {
        try
        {
            _logger.LogInformation("Kullanıcı {UserId} için {ReportType} raporu oluşturuluyor", userId, request.Type);

            // Rapor verilerini oluştur
            var reportData = await GenerateReportDataAsync(userId, request);

            // Raporu kaydet (eğer isteniyorsa)
            if (request.SaveReport)
            {
                var report = new Report
                {
                    UserId = userId,
                    Title = request.Title,
                    Type = request.Type,
                    Period = request.Period,
                    StartDate = request.StartDate,
                    EndDate = request.EndDate,
                    Description = request.Description,
                    FilterCriteria = request.Filters != null ? JsonSerializer.Serialize(request.Filters) : null,
                    GeneratedAt = DateTime.UtcNow
                };

                await _unitOfWork.Reports.AddAsync(report);
                await _unitOfWork.CompleteAsync();
                reportData.Report = _mapper.Map<ReportDto>(report);
            }

            _logger.LogInformation("Rapor başarıyla oluşturuldu");
            return Result<ReportDataDto>.Success(reportData);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Rapor oluşturulurken hata oluştu");
            return Result<ReportDataDto>.Failure("Rapor oluşturulurken bir hata oluştu");
        }
    }

    /// <summary>
    /// Kullanıcının raporlarını getirir
    /// </summary>
    public async Task<Result<List<ReportDto>>> GetUserReportsAsync(int userId, int page = 1, int pageSize = 10)
    {
        try
        {
            var reports = await _unitOfWork.Reports.GetUserReportsAsync(userId, page, pageSize);
            var reportDtos = _mapper.Map<List<ReportDto>>(reports);

            // Enum değerlerini string'e çevir
            foreach (var dto in reportDtos)
            {
                dto.TypeName = GetReportTypeName(dto.Type);
                dto.PeriodName = GetReportPeriodName(dto.Period);
            }

            return Result<List<ReportDto>>.Success(reportDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kullanıcı raporları getirilirken hata oluştu");
            return Result<List<ReportDto>>.Failure("Raporlar getirilirken bir hata oluştu");
        }
    }

    /// <summary>
    /// Belirli bir raporu getirir
    /// </summary>
    public async Task<Result<ReportDataDto>> GetReportByIdAsync(int userId, int reportId)
    {
        try
        {
            var report = await _unitOfWork.Reports.GetUserReportByIdAsync(userId, reportId);
            if (report == null)
            {
                return Result<ReportDataDto>.Failure("Rapor bulunamadı");
            }

            // Rapor verilerini yeniden oluştur
            var filters = !string.IsNullOrEmpty(report.FilterCriteria)
                ? JsonSerializer.Deserialize<ReportFilterDto>(report.FilterCriteria)
                : null;

            var request = new CreateReportRequestDto
            {
                Title = report.Title,
                Type = report.Type,
                Period = report.Period,
                StartDate = report.StartDate,
                EndDate = report.EndDate,
                Description = report.Description,
                Filters = filters
            };

            var reportData = await GenerateReportDataAsync(userId, request);
            reportData.Report = _mapper.Map<ReportDto>(report);
            reportData.Report.TypeName = GetReportTypeName(report.Type);
            reportData.Report.PeriodName = GetReportPeriodName(report.Period);

            return Result<ReportDataDto>.Success(reportData);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Rapor getirilirken hata oluştu");
            return Result<ReportDataDto>.Failure("Rapor getirilirken bir hata oluştu");
        }
    }

    /// <summary>
    /// Rapor siler
    /// </summary>
    public async Task<Result<bool>> DeleteReportAsync(int userId, int reportId)
    {
        try
        {
            var report = await _unitOfWork.Reports.GetUserReportByIdAsync(userId, reportId);
            if (report == null)
            {
                return Result<bool>.Failure("Rapor bulunamadı");
            }

            await _unitOfWork.Reports.DeleteAsync(report);
            await _unitOfWork.CompleteAsync();
            return Result<bool>.Success(true);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Rapor silinirken hata oluştu");
            return Result<bool>.Failure("Rapor silinirken bir hata oluştu");
        }
    }

    /// <summary>
    /// Raporu dışa aktarır
    /// </summary>
    public async Task<Result<byte[]>> ExportReportAsync(int userId, int reportId, ReportFormat format)
    {
        try
        {
            var reportResult = await GetReportByIdAsync(userId, reportId);
            if (!reportResult.IsSuccess)
            {
                return Result<byte[]>.Failure(reportResult.Errors.FirstOrDefault() ?? "Rapor bulunamadı");
            }

            var reportData = reportResult.Value;

            if (reportData == null)
            {
                return Result<byte[]>.Failure("Rapor verileri bulunamadı");
            }

            byte[] fileBytes = format switch
            {
                ReportFormat.PDF => await _pdfGeneratorService.GeneratePdfAsync(reportData),
                ReportFormat.Excel => await _excelGeneratorService.GenerateExcelAsync(reportData),
                ReportFormat.CSV => await _excelGeneratorService.GenerateCsvAsync(reportData),
                _ => throw new ArgumentException("Desteklenmeyen format")
            };

            return Result<byte[]>.Success(fileBytes);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Rapor dışa aktarılırken hata oluştu");
            return Result<byte[]>.Failure("Rapor dışa aktarılırken bir hata oluştu");
        }
    }

    /// <summary>
    /// Hızlı rapor oluşturur
    /// </summary>
    public async Task<Result<ReportDataDto>> GetQuickReportAsync(int userId, ReportType type, ReportPeriod period)
    {
        try
        {
            var (startDate, endDate) = GetDateRangeForPeriod(period);

            var request = new CreateReportRequestDto
            {
                Title = $"{GetReportTypeName(type)} - {GetReportPeriodName(period)}",
                Type = type,
                Period = period,
                StartDate = startDate,
                EndDate = endDate,
                SaveReport = false // Hızlı raporlar kaydedilmez
            };

            return await GenerateReportAsync(userId, request);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Hızlı rapor oluşturulurken hata oluştu");
            return Result<ReportDataDto>.Failure("Hızlı rapor oluşturulurken bir hata oluştu");
        }
    }

    /// <summary>
    /// Rapor verilerini oluşturur
    /// </summary>
    private async Task<ReportDataDto> GenerateReportDataAsync(int userId, CreateReportRequestDto request)
    {
        var reportData = new ReportDataDto
        {
            Report = new ReportDto
            {
                Title = request.Title,
                Type = request.Type,
                Period = request.Period,
                StartDate = request.StartDate,
                EndDate = request.EndDate,
                Description = request.Description,
                GeneratedAt = DateTime.UtcNow,
                TypeName = GetReportTypeName(request.Type),
                PeriodName = GetReportPeriodName(request.Period)
            }
        };

        // Temel finansal özet
        reportData.Summary = await GenerateFinancialSummaryAsync(userId, request);

        // Rapor türüne göre özel veriler
        switch (request.Type)
        {
            case ReportType.IncomeExpenseAnalysis:
            case ReportType.MonthlyFinancialSummary:
            case ReportType.YearlyFinancialSummary:
                await GenerateIncomeExpenseDataAsync(userId, request, reportData);
                break;

            case ReportType.BudgetPerformance:
                await GenerateBudgetPerformanceDataAsync(userId, request, reportData);
                break;

            case ReportType.CategoryAnalysis:
                await GenerateCategoryAnalysisDataAsync(userId, request, reportData);
                break;

            case ReportType.AccountSummary:
                await GenerateAccountSummaryDataAsync(userId, request, reportData);
                break;

            case ReportType.CashFlowAnalysis:
                await GenerateCashFlowDataAsync(userId, request, reportData);
                break;
        }

        return reportData;
    }

    /// <summary>
    /// Finansal özet oluşturur
    /// </summary>
    private async Task<FinancialSummaryDto> GenerateFinancialSummaryAsync(int userId, CreateReportRequestDto request)
    {
        var transactions = await _unitOfWork.Reports.GetTransactionsByDateRangeAsync(
            userId, request.StartDate, request.EndDate,
            request.Filters?.CategoryIds, request.Filters?.AccountIds);

        var incomeTransactions = transactions.Where(t => t.Category.Type == CategoryType.Income);
        var expenseTransactions = transactions.Where(t => t.Category.Type == CategoryType.Expense);

        var totalIncome = incomeTransactions.Sum(t => t.Amount);
        var totalExpense = expenseTransactions.Sum(t => t.Amount);

        // Bütçe bilgileri
        var budgets = await _unitOfWork.Reports.GetBudgetsByDateRangeAsync(
            userId, request.StartDate, request.EndDate, request.Filters?.CategoryIds);
        var totalBudget = budgets.Sum(b => b.Amount);

        return new FinancialSummaryDto
        {
            TotalIncome = totalIncome,
            TotalExpense = totalExpense,
            NetAmount = totalIncome - totalExpense,
            TotalBudget = totalBudget,
            BudgetUtilization = totalBudget > 0 ? (totalExpense / totalBudget) * 100 : 0,
            TransactionCount = transactions.Count
        };
    }

    /// <summary>
    /// Gelir-Gider analizi verilerini oluşturur
    /// </summary>
    private async Task GenerateIncomeExpenseDataAsync(int userId, CreateReportRequestDto request, ReportDataDto reportData)
    {
        var categoryAnalysis = await _unitOfWork.Reports.GetCategoryAnalysisAsync(
            userId, request.StartDate, request.EndDate, request.Filters?.CategoryIds);

        reportData.CategoryAnalysis = categoryAnalysis.Select(ca => new CategoryAnalysisDto
        {
            CategoryId = ca.CategoryId,
            CategoryName = ca.CategoryName,
            CategoryType = ca.CategoryType.ToString(),
            Amount = ca.TotalAmount,
            Percentage = reportData.Summary.TotalExpense > 0 && ca.CategoryType == CategoryType.Expense
                ? (ca.TotalAmount / reportData.Summary.TotalExpense) * 100
                : reportData.Summary.TotalIncome > 0 && ca.CategoryType == CategoryType.Income
                    ? (ca.TotalAmount / reportData.Summary.TotalIncome) * 100
                    : 0,
            TransactionCount = ca.TransactionCount,
            BudgetAmount = ca.BudgetAmount
        }).ToList();

        // Grafik verileri
        reportData.Charts.Add(new ChartDataDto
        {
            ChartType = "pie",
            Title = "Gider Dağılımı",
            Data = reportData.CategoryAnalysis
                .Where(ca => ca.CategoryType == "Expense")
                .Select(ca => new ChartPointDto
                {
                    Label = ca.CategoryName,
                    Value = ca.Amount
                }).ToList()
        });

        reportData.Charts.Add(new ChartDataDto
        {
            ChartType = "bar",
            Title = "Gelir vs Gider",
            Data = new List<ChartPointDto>
            {
                new() { Label = "Gelir", Value = reportData.Summary.TotalIncome },
                new() { Label = "Gider", Value = reportData.Summary.TotalExpense }
            }
        });
    }

    /// <summary>
    /// Bütçe performans verilerini oluşturur
    /// </summary>
    private async Task GenerateBudgetPerformanceDataAsync(int userId, CreateReportRequestDto request, ReportDataDto reportData)
    {
        var budgetPerformance = await _unitOfWork.Reports.GetBudgetPerformanceAsync(
            userId, request.StartDate, request.EndDate, request.Filters?.CategoryIds);

        var budgetCategories = budgetPerformance.Select(bp => new BudgetCategoryDto
        {
            CategoryId = bp.CategoryId,
            CategoryName = bp.CategoryName,
            BudgetAmount = bp.BudgetAmount,
            SpentAmount = bp.SpentAmount,
            RemainingAmount = bp.BudgetAmount - bp.SpentAmount,
            UtilizationPercentage = bp.BudgetAmount > 0 ? (bp.SpentAmount / bp.BudgetAmount) * 100 : 0,
            IsOverBudget = bp.SpentAmount > bp.BudgetAmount
        }).ToList();

        reportData.BudgetPerformance = new BudgetPerformanceDto
        {
            TotalBudget = budgetCategories.Sum(bc => bc.BudgetAmount),
            TotalSpent = budgetCategories.Sum(bc => bc.SpentAmount),
            Remaining = budgetCategories.Sum(bc => bc.RemainingAmount),
            UtilizationPercentage = reportData.Summary.BudgetUtilization,
            Categories = budgetCategories
        };

        // Bütçe performans grafiği
        reportData.Charts.Add(new ChartDataDto
        {
            ChartType = "bar",
            Title = "Bütçe vs Harcama",
            Data = budgetCategories.Select(bc => new ChartPointDto
            {
                Label = bc.CategoryName,
                Value = bc.UtilizationPercentage
            }).ToList()
        });
    }

    /// <summary>
    /// Kategori analizi verilerini oluşturur
    /// </summary>
    private async Task GenerateCategoryAnalysisDataAsync(int userId, CreateReportRequestDto request, ReportDataDto reportData)
    {
        await GenerateIncomeExpenseDataAsync(userId, request, reportData);

        // Ek kategori grafikleri
        reportData.Charts.Add(new ChartDataDto
        {
            ChartType = "pie",
            Title = "Gelir Kaynakları",
            Data = reportData.CategoryAnalysis
                .Where(ca => ca.CategoryType == "Income")
                .Select(ca => new ChartPointDto
                {
                    Label = ca.CategoryName,
                    Value = ca.Amount
                }).ToList()
        });
    }

    /// <summary>
    /// Hesap özeti verilerini oluşturur
    /// </summary>
    private async Task GenerateAccountSummaryDataAsync(int userId, CreateReportRequestDto request, ReportDataDto reportData)
    {
        var accountSummaries = await _unitOfWork.Reports.GetAccountSummaryAsync(
            userId, request.StartDate, request.EndDate, request.Filters?.AccountIds);

        reportData.AccountSummaries = accountSummaries.Select(acs => new AccountSummaryDto
        {
            AccountId = acs.AccountId,
            AccountName = acs.AccountName,
            AccountType = acs.AccountType.ToString(),
            InitialBalance = acs.InitialBalance,
            CurrentBalance = acs.InitialBalance + acs.TotalIncome - acs.TotalExpense,
            TotalIncome = acs.TotalIncome,
            TotalExpense = acs.TotalExpense,
            TransactionCount = acs.TransactionCount
        }).ToList();

        // Hesap bakiye grafiği
        reportData.Charts.Add(new ChartDataDto
        {
            ChartType = "bar",
            Title = "Hesap Bakiyeleri",
            Data = reportData.AccountSummaries.Select(acs => new ChartPointDto
            {
                Label = acs.AccountName,
                Value = acs.CurrentBalance
            }).ToList()
        });
    }

    /// <summary>
    /// Nakit akış verilerini oluşturur
    /// </summary>
    private async Task GenerateCashFlowDataAsync(int userId, CreateReportRequestDto request, ReportDataDto reportData)
    {
        // Günlük nakit akış verilerini hesapla
        var transactions = await _unitOfWork.Reports.GetTransactionsByDateRangeAsync(
            userId, request.StartDate, request.EndDate);

        var dailyCashFlow = transactions
            .GroupBy(t => t.TransactionDate.Date)
            .Select(g => new ChartPointDto
            {
                Label = g.Key.ToString("dd/MM"),
                Value = g.Where(t => t.Category.Type == CategoryType.Income).Sum(t => t.Amount) -
                       g.Where(t => t.Category.Type == CategoryType.Expense).Sum(t => t.Amount),
                Date = g.Key
            })
            .OrderBy(cf => cf.Date)
            .ToList();

        reportData.Charts.Add(new ChartDataDto
        {
            ChartType = "line",
            Title = "Günlük Nakit Akışı",
            Data = dailyCashFlow
        });
    }

    /// <summary>
    /// Dönem için tarih aralığını hesaplar
    /// </summary>
    private (DateTime startDate, DateTime endDate) GetDateRangeForPeriod(ReportPeriod period)
    {
        var now = DateTime.Now;
        return period switch
        {
            ReportPeriod.Daily => (now.Date, now.Date.AddDays(1).AddTicks(-1)),
            ReportPeriod.Weekly => (now.AddDays(-7), now),
            ReportPeriod.Monthly => (new DateTime(now.Year, now.Month, 1), new DateTime(now.Year, now.Month, 1).AddMonths(1).AddTicks(-1)),
            ReportPeriod.Quarterly => (now.AddMonths(-3), now),
            ReportPeriod.Yearly => (new DateTime(now.Year, 1, 1), new DateTime(now.Year, 12, 31)),
            _ => (now.AddMonths(-1), now)
        };
    }

    /// <summary>
    /// Rapor türü adını getirir
    /// </summary>
    private string GetReportTypeName(ReportType type) => type switch
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
    /// Rapor dönem adını getirir
    /// </summary>
    private string GetReportPeriodName(ReportPeriod period) => period switch
    {
        ReportPeriod.Daily => "Günlük",
        ReportPeriod.Weekly => "Haftalık",
        ReportPeriod.Monthly => "Aylık",
        ReportPeriod.Quarterly => "Üç Aylık",
        ReportPeriod.Yearly => "Yıllık",
        ReportPeriod.Custom => "Özel Dönem",
        _ => "Bilinmeyen Dönem"
    };
}