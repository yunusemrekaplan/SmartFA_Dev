// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetModel _$BudgetModelFromJson(Map<String, dynamic> json) => BudgetModel(
      id: (json['id'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      categoryIcon: json['categoryIcon'] as String?,
      amount: (json['amount'] as num).toDouble(),
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
    );

Map<String, dynamic> _$BudgetModelToJson(BudgetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'categoryIcon': instance.categoryIcon,
      'amount': instance.amount,
      'month': instance.month,
      'year': instance.year,
      'spentAmount': instance.spentAmount,
      'remainingAmount': instance.remainingAmount,
    };
