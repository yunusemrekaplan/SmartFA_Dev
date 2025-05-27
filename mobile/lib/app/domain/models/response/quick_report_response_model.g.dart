// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_report_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuickReportResponseModel _$QuickReportResponseModelFromJson(
        Map<String, dynamic> json) =>
    QuickReportResponseModel(
      report: ReportModel.fromJson(json['report'] as Map<String, dynamic>),
      summary:
          ReportSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
      charts: (json['charts'] as List<dynamic>)
          .map((e) => ChartModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryAnalysis: (json['categoryAnalysis'] as List<dynamic>?)
          ?.map(
              (e) => CategoryAnalysisModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountSummaries: (json['accountSummaries'] as List<dynamic>?)
          ?.map((e) => AccountSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      budgetPerformance: json['budgetPerformance'] == null
          ? null
          : BudgetPerformanceWrapperModel.fromJson(
              json['budgetPerformance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuickReportResponseModelToJson(
        QuickReportResponseModel instance) =>
    <String, dynamic>{
      'report': instance.report,
      'summary': instance.summary,
      'charts': instance.charts,
      'categoryAnalysis': instance.categoryAnalysis,
      'accountSummaries': instance.accountSummaries,
      'budgetPerformance': instance.budgetPerformance,
    };

ReportSummaryModel _$ReportSummaryModelFromJson(Map<String, dynamic> json) =>
    ReportSummaryModel(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0,
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0,
      budgetUtilization: (json['budgetUtilization'] as num?)?.toDouble() ?? 0,
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ReportSummaryModelToJson(ReportSummaryModel instance) =>
    <String, dynamic>{
      'totalIncome': instance.totalIncome,
      'totalExpense': instance.totalExpense,
      'netAmount': instance.netAmount,
      'totalBudget': instance.totalBudget,
      'budgetUtilization': instance.budgetUtilization,
      'transactionCount': instance.transactionCount,
    };

ChartModel _$ChartModelFromJson(Map<String, dynamic> json) => ChartModel(
      chartType: json['chartType'] as String,
      title: json['title'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => ChartDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChartModelToJson(ChartModel instance) =>
    <String, dynamic>{
      'chartType': instance.chartType,
      'title': instance.title,
      'data': instance.data,
    };

ChartDataModel _$ChartDataModelFromJson(Map<String, dynamic> json) =>
    ChartDataModel(
      label: json['label'] as String,
      value: (json['value'] as num?)?.toDouble() ?? 0,
      color: json['color'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$ChartDataModelToJson(ChartDataModel instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      'color': instance.color,
      'date': instance.date?.toIso8601String(),
    };

BudgetPerformanceWrapperModel _$BudgetPerformanceWrapperModelFromJson(
        Map<String, dynamic> json) =>
    BudgetPerformanceWrapperModel(
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0,
      utilizationPercentage:
          (json['utilizationPercentage'] as num?)?.toDouble() ?? 0,
      categories: (json['categories'] as List<dynamic>)
          .map(
              (e) => BudgetPerformanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BudgetPerformanceWrapperModelToJson(
        BudgetPerformanceWrapperModel instance) =>
    <String, dynamic>{
      'totalBudget': instance.totalBudget,
      'totalSpent': instance.totalSpent,
      'remaining': instance.remaining,
      'utilizationPercentage': instance.utilizationPercentage,
      'categories': instance.categories,
    };
