// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_response_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      type: reportTypeFromJson((json['type'] as num).toInt()),
      period: reportPeriodFromJson((json['period'] as num).toInt()),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      description: json['description'] as String?,
      filterCriteria: json['filterCriteria'] as Map<String, dynamic>?,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      filePath: json['filePath'] as String?,
      isScheduled: json['isScheduled'] as bool,
    );

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': reportTypeToJson(instance.type),
      'period': reportPeriodToJson(instance.period),
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'description': instance.description,
      'filterCriteria': instance.filterCriteria,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'filePath': instance.filePath,
      'isScheduled': instance.isScheduled,
    };

FinancialSummaryModel _$FinancialSummaryModelFromJson(
        Map<String, dynamic> json) =>
    FinancialSummaryModel(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
      netIncome: (json['netIncome'] as num).toDouble(),
      savingsRate: (json['savingsRate'] as num).toDouble(),
      categoryBreakdown: (json['categoryBreakdown'] as List<dynamic>)
          .map((e) => CategorySummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FinancialSummaryModelToJson(
        FinancialSummaryModel instance) =>
    <String, dynamic>{
      'totalIncome': instance.totalIncome,
      'totalExpense': instance.totalExpense,
      'netIncome': instance.netIncome,
      'savingsRate': instance.savingsRate,
      'categoryBreakdown': instance.categoryBreakdown,
    };

CategorySummaryModel _$CategorySummaryModelFromJson(
        Map<String, dynamic> json) =>
    CategorySummaryModel(
      categoryName: json['categoryName'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$CategorySummaryModelToJson(
        CategorySummaryModel instance) =>
    <String, dynamic>{
      'categoryName': instance.categoryName,
      'amount': instance.amount,
      'percentage': instance.percentage,
    };

CategoryAnalysisModel _$CategoryAnalysisModelFromJson(
        Map<String, dynamic> json) =>
    CategoryAnalysisModel(
      categoryId: (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      categoryType: json['categoryType'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      transactionCount: (json['transactionCount'] as num).toInt(),
      budgetAmount: (json['budgetAmount'] as num?)?.toDouble(),
      budgetUtilization: (json['budgetUtilization'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CategoryAnalysisModelToJson(
        CategoryAnalysisModel instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'categoryType': instance.categoryType,
      'amount': instance.amount,
      'percentage': instance.percentage,
      'transactionCount': instance.transactionCount,
      'budgetAmount': instance.budgetAmount,
      'budgetUtilization': instance.budgetUtilization,
    };

BudgetPerformanceModel _$BudgetPerformanceModelFromJson(
        Map<String, dynamic> json) =>
    BudgetPerformanceModel(
      categoryName: json['categoryName'] as String,
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      utilizationPercentage: (json['utilizationPercentage'] as num).toDouble(),
      isOverBudget: json['isOverBudget'] as bool,
    );

Map<String, dynamic> _$BudgetPerformanceModelToJson(
        BudgetPerformanceModel instance) =>
    <String, dynamic>{
      'categoryName': instance.categoryName,
      'budgetAmount': instance.budgetAmount,
      'spentAmount': instance.spentAmount,
      'remainingAmount': instance.remainingAmount,
      'utilizationPercentage': instance.utilizationPercentage,
      'isOverBudget': instance.isOverBudget,
    };

AccountSummaryModel _$AccountSummaryModelFromJson(Map<String, dynamic> json) =>
    AccountSummaryModel(
      accountName: json['accountName'] as String,
      currentBalance: (json['currentBalance'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
      transactionCount: (json['transactionCount'] as num).toInt(),
    );

Map<String, dynamic> _$AccountSummaryModelToJson(
        AccountSummaryModel instance) =>
    <String, dynamic>{
      'accountName': instance.accountName,
      'currentBalance': instance.currentBalance,
      'totalIncome': instance.totalIncome,
      'totalExpense': instance.totalExpense,
      'transactionCount': instance.transactionCount,
    };

ChartDataModel _$ChartDataModelFromJson(Map<String, dynamic> json) =>
    ChartDataModel(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      color: json['color'] as String?,
    );

Map<String, dynamic> _$ChartDataModelToJson(ChartDataModel instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      'color': instance.color,
    };

ReportDataModel _$ReportDataModelFromJson(Map<String, dynamic> json) =>
    ReportDataModel(
      financialSummary: json['financialSummary'] == null
          ? null
          : FinancialSummaryModel.fromJson(
              json['financialSummary'] as Map<String, dynamic>),
      categoryAnalysis: (json['categoryAnalysis'] as List<dynamic>?)
          ?.map(
              (e) => CategoryAnalysisModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      budgetPerformance: (json['budgetPerformance'] as List<dynamic>?)
          ?.map(
              (e) => BudgetPerformanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountSummary: (json['accountSummary'] as List<dynamic>?)
          ?.map((e) => AccountSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      chartData: (json['chartData'] as List<dynamic>?)
          ?.map((e) => ChartDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReportDataModelToJson(ReportDataModel instance) =>
    <String, dynamic>{
      'financialSummary': instance.financialSummary,
      'categoryAnalysis': instance.categoryAnalysis,
      'budgetPerformance': instance.budgetPerformance,
      'accountSummary': instance.accountSummary,
      'chartData': instance.chartData,
      'additionalData': instance.additionalData,
    };
