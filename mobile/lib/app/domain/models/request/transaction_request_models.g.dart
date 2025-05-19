// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateTransactionRequestModelToJson(
        CreateTransactionRequestModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'categoryId': instance.categoryId,
      'amount': instance.amount,
      'transactionDate': _dateTimeToJson(instance.transactionDate),
      'notes': instance.notes,
    };

Map<String, dynamic> _$UpdateTransactionRequestModelToJson(
        UpdateTransactionRequestModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'categoryId': instance.categoryId,
      'amount': instance.amount,
      'transactionDate': _dateTimeToJson(instance.transactionDate),
      'notes': instance.notes,
    };
