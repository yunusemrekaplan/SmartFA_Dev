import 'package:json_annotation/json_annotation.dart';
import 'report_response_models.dart';

part 'quick_report_response_model.g.dart';

@JsonSerializable()
class QuickReportResponseModel {
  final ReportModel report;
  final ReportSummaryModel summary;
  final List<ChartModel> charts;
  final List<CategoryAnalysisModel>? categoryAnalysis;
  final List<AccountSummaryModel>? accountSummaries;
  final BudgetPerformanceWrapperModel? budgetPerformance;

  QuickReportResponseModel({
    required this.report,
    required this.summary,
    required this.charts,
    this.categoryAnalysis,
    this.accountSummaries,
    this.budgetPerformance,
  });

  factory QuickReportResponseModel.fromJson(Map<String, dynamic> json) =>
      _$QuickReportResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuickReportResponseModelToJson(this);
}

@JsonSerializable()
class ReportSummaryModel {
  final double? totalIncome;
  final double? totalExpense;
  final double? netAmount;
  final double? totalBudget;
  final double? budgetUtilization;
  final int? transactionCount;

  ReportSummaryModel({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.netAmount = 0,
    this.totalBudget = 0,
    this.budgetUtilization = 0,
    this.transactionCount = 0,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryModelToJson(this);
}

@JsonSerializable()
class ChartModel {
  final String chartType;
  final String title;
  final List<ChartDataModel> data;

  ChartModel({
    required this.chartType,
    required this.title,
    required this.data,
  });

  factory ChartModel.fromJson(Map<String, dynamic> json) =>
      _$ChartModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChartModelToJson(this);
}

@JsonSerializable()
class ChartDataModel {
  final String label;
  final double? value;
  final String? color;
  final DateTime? date;

  ChartDataModel({
    required this.label,
    this.value = 0,
    this.color,
    this.date,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) =>
      _$ChartDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChartDataModelToJson(this);
}

@JsonSerializable()
class BudgetPerformanceWrapperModel {
  final double? totalBudget;
  final double? totalSpent;
  final double? remaining;
  final double? utilizationPercentage;
  final List<BudgetPerformanceModel> categories;

  BudgetPerformanceWrapperModel({
    this.totalBudget = 0,
    this.totalSpent = 0,
    this.remaining = 0,
    this.utilizationPercentage = 0,
    required this.categories,
  });

  factory BudgetPerformanceWrapperModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetPerformanceWrapperModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetPerformanceWrapperModelToJson(this);
}
