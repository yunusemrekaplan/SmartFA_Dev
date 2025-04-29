// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_payment_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtPaymentModel _$DebtPaymentModelFromJson(Map<String, dynamic> json) =>
    DebtPaymentModel(
      id: (json['id'] as num).toInt(),
      debtId: (json['debtId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DebtPaymentModelToJson(DebtPaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'debtId': instance.debtId,
      'amount': instance.amount,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'notes': instance.notes,
    };
