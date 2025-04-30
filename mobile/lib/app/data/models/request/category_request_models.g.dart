// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateCategoryRequestModelToJson(
        CreateCategoryRequestModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': categoryTypeToJson(instance.type),
      'iconName': instance.iconName,
    };

Map<String, dynamic> _$UpdateCategoryRequestModelToJson(
        UpdateCategoryRequestModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'iconName': instance.iconName,
    };
