// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateAccountRequestModelToJson(
        CreateAccountRequestModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _accountTypeToJson(instance.type),
      'currency': instance.currency,
      'initialBalance': instance.initialBalance,
    };

Map<String, dynamic> _$UpdateAccountRequestModelToJson(
        UpdateAccountRequestModel instance) =>
    <String, dynamic>{
      'name': instance.name,
    };
