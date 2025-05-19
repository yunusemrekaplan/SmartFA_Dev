// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtModel _$DebtModelFromJson(Map<String, dynamic> json) => DebtModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      lenderName: json['lenderName'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      isPaidOff: json['isPaidOff'] as bool,
    );

Map<String, dynamic> _$DebtModelToJson(DebtModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'lenderName': instance.lenderName,
      'totalAmount': instance.totalAmount,
      'remainingAmount': instance.remainingAmount,
      'currency': instance.currency,
      'isPaidOff': instance.isPaidOff,
    };
