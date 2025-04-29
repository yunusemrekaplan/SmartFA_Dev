// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: (json['id'] as num).toInt(),
      accountId: (json['accountId'] as num).toInt(),
      accountName: json['accountName'] as String,
      categoryId: (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      categoryIcon: json['categoryIcon'] as String?,
      categoryType: $enumDecode(_$CategoryTypeEnumMap, json['categoryType']),
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'categoryIcon': instance.categoryIcon,
      'categoryType': _$CategoryTypeEnumMap[instance.categoryType]!,
      'amount': instance.amount,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'notes': instance.notes,
    };

const _$CategoryTypeEnumMap = {
  CategoryType.Income: 1,
  CategoryType.Expense: 2,
};
