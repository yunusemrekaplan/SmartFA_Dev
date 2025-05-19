// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) => AccountModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: $enumDecode(_$AccountTypeEnumMap, json['type']),
      currency: json['currency'] as String,
      currentBalance: (json['currentBalance'] as num).toDouble(),
    );

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'currency': instance.currency,
      'currentBalance': instance.currentBalance,
    };

const _$AccountTypeEnumMap = {
  AccountType.Cash: 1,
  AccountType.Bank: 2,
  AccountType.CreditCard: 3,
};
