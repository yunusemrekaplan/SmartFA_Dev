import 'package:json_annotation/json_annotation.dart';

enum ReportType {
  @JsonValue(1)
  IncomeExpenseAnalysis,
  @JsonValue(2)
  BudgetPerformance,
  @JsonValue(3)
  CategoryAnalysis,
  @JsonValue(4)
  AccountSummary,
  @JsonValue(5)
  CashFlowAnalysis,
  @JsonValue(6)
  MonthlyFinancialSummary,
  @JsonValue(7)
  YearlyFinancialSummary,
  @JsonValue(8)
  CustomReport,
}

// Enum helper fonksiyonları
int reportTypeToJson(ReportType type) {
  switch (type) {
    case ReportType.IncomeExpenseAnalysis:
      return 1;
    case ReportType.BudgetPerformance:
      return 2;
    case ReportType.CategoryAnalysis:
      return 3;
    case ReportType.AccountSummary:
      return 4;
    case ReportType.CashFlowAnalysis:
      return 5;
    case ReportType.MonthlyFinancialSummary:
      return 6;
    case ReportType.YearlyFinancialSummary:
      return 7;
    case ReportType.CustomReport:
      return 8;
  }
}

ReportType reportTypeFromJson(int value) {
  switch (value) {
    case 1:
      return ReportType.IncomeExpenseAnalysis;
    case 2:
      return ReportType.BudgetPerformance;
    case 3:
      return ReportType.CategoryAnalysis;
    case 4:
      return ReportType.AccountSummary;
    case 5:
      return ReportType.CashFlowAnalysis;
    case 6:
      return ReportType.MonthlyFinancialSummary;
    case 7:
      return ReportType.YearlyFinancialSummary;
    case 8:
      return ReportType.CustomReport;
    default:
      throw ArgumentError('Invalid ReportType value: $value');
  }
}

// Extension for display names
extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.IncomeExpenseAnalysis:
        return 'Gelir-Gider Analizi';
      case ReportType.BudgetPerformance:
        return 'Bütçe Performansı';
      case ReportType.CategoryAnalysis:
        return 'Kategori Analizi';
      case ReportType.AccountSummary:
        return 'Hesap Özeti';
      case ReportType.CashFlowAnalysis:
        return 'Nakit Akış Analizi';
      case ReportType.MonthlyFinancialSummary:
        return 'Aylık Finansal Özet';
      case ReportType.YearlyFinancialSummary:
        return 'Yıllık Finansal Özet';
      case ReportType.CustomReport:
        return 'Özel Rapor';
    }
  }
}
