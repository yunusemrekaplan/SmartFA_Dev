import 'package:json_annotation/json_annotation.dart';
import '../enums/report_type.dart';
import '../enums/report_period.dart';

part 'report_response_models.g.dart';

// Ana ReportModel - Backend ReportDto'ya karşılık gelir
@JsonSerializable()
class ReportModel {
  final int id;
  final String title;
  @JsonKey(fromJson: reportTypeFromJson, toJson: reportTypeToJson)
  final ReportType type;
  @JsonKey(fromJson: reportPeriodFromJson, toJson: reportPeriodToJson)
  final ReportPeriod period;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final Map<String, dynamic>? filterCriteria;
  final DateTime generatedAt;
  final String? filePath;
  final bool isScheduled;

  ReportModel({
    required this.id,
    required this.title,
    required this.type,
    required this.period,
    this.startDate,
    this.endDate,
    this.description,
    this.filterCriteria,
    required this.generatedAt,
    this.filePath,
    required this.isScheduled,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReportModel(id: $id, title: $title, type: $type, period: $period)';
  }
}

// Finansal Özet Modeli - Backend FinancialSummaryDto'ya karşılık gelir
@JsonSerializable()
class FinancialSummaryModel {
  final double totalIncome;
  final double totalExpense;
  final double netIncome;
  final double savingsRate;
  final List<CategorySummaryModel> categoryBreakdown;

  FinancialSummaryModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.netIncome,
    required this.savingsRate,
    required this.categoryBreakdown,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$FinancialSummaryModelToJson(this);
}

// Kategori Özeti Modeli
@JsonSerializable()
class CategorySummaryModel {
  final String categoryName;
  final double amount;
  final double percentage;

  CategorySummaryModel({
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  factory CategorySummaryModel.fromJson(Map<String, dynamic> json) =>
      _$CategorySummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategorySummaryModelToJson(this);
}

// Kategori Analizi Modeli - Backend CategoryAnalysisDto'ya karşılık gelir
@JsonSerializable()
class CategoryAnalysisModel {
  final int categoryId;
  final String categoryName;
  final String categoryType;
  final double amount;
  final double percentage;
  final int transactionCount;
  final double? budgetAmount;
  final double? budgetUtilization;

  CategoryAnalysisModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    this.budgetAmount,
    this.budgetUtilization,
  });

  factory CategoryAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryAnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryAnalysisModelToJson(this);
}

// Bütçe Performansı Modeli - Backend BudgetPerformanceDto'ya karşılık gelir
@JsonSerializable()
class BudgetPerformanceModel {
  final String categoryName;
  final double budgetAmount;
  final double spentAmount;
  final double remainingAmount;
  final double utilizationPercentage;
  final bool isOverBudget;

  BudgetPerformanceModel({
    required this.categoryName,
    required this.budgetAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.utilizationPercentage,
    required this.isOverBudget,
  });

  factory BudgetPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetPerformanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetPerformanceModelToJson(this);
}

// Hesap Özeti Modeli - Backend AccountSummaryDto'ya karşılık gelir
@JsonSerializable()
class AccountSummaryModel {
  final String accountName;
  final double currentBalance;
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;

  AccountSummaryModel({
    required this.accountName,
    required this.currentBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
  });

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$AccountSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountSummaryModelToJson(this);
}

// Grafik Verisi Modeli - Backend ChartDataDto'ya karşılık gelir
@JsonSerializable()
class ChartDataModel {
  final String label;
  final double value;
  final String? color;

  ChartDataModel({
    required this.label,
    required this.value,
    this.color,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) =>
      _$ChartDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChartDataModelToJson(this);
}

// Rapor Verisi Modeli - Backend ReportDataDto'ya karşılık gelir
@JsonSerializable()
class ReportDataModel {
  final FinancialSummaryModel? financialSummary;
  final List<CategoryAnalysisModel>? categoryAnalysis;
  final List<BudgetPerformanceModel>? budgetPerformance;
  final List<AccountSummaryModel>? accountSummary;
  final List<ChartDataModel>? chartData;
  final Map<String, dynamic>? additionalData;

  ReportDataModel({
    this.financialSummary,
    this.categoryAnalysis,
    this.budgetPerformance,
    this.accountSummary,
    this.chartData,
    this.additionalData,
  });

  factory ReportDataModel.fromJson(Map<String, dynamic> json) =>
      _$ReportDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDataModelToJson(this);
}
