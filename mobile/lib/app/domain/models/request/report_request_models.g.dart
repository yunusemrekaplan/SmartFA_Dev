// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateReportRequestModelToJson(
        CreateReportRequestModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'type': reportTypeToJson(instance.type),
      'period': reportPeriodToJson(instance.period),
      'startDate': _dateTimeToJson(instance.startDate),
      'endDate': _dateTimeToJson(instance.endDate),
      'description': instance.description,
      'filterCriteria': instance.filterCriteria,
      'isScheduled': instance.isScheduled,
    };

Map<String, dynamic> _$QuickReportRequestModelToJson(
        QuickReportRequestModel instance) =>
    <String, dynamic>{
      'type': reportTypeToJson(instance.type),
      'period': reportPeriodToJson(instance.period),
      'startDate': _dateTimeToJson(instance.startDate),
      'endDate': _dateTimeToJson(instance.endDate),
    };

Map<String, dynamic> _$ExportReportRequestModelToJson(
        ExportReportRequestModel instance) =>
    <String, dynamic>{
      'reportId': instance.reportId,
      'format': reportFormatToJson(instance.format),
    };
