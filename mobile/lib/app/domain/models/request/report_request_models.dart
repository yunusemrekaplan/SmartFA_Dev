import 'package:json_annotation/json_annotation.dart';
import '../enums/report_type.dart';
import '../enums/report_period.dart';
import '../enums/report_format.dart';

part 'report_request_models.g.dart';

// DateTime'ı ISO 8601 formatında string'e çeviren yardımcı fonksiyon
String? _dateTimeToJson(DateTime? dateTime) => dateTime?.toIso8601String();

// Rapor Oluşturma Request Modeli - Backend CreateReportRequestDto'ya karşılık gelir
@JsonSerializable(createFactory: false)
class CreateReportRequestModel {
  final String title;
  @JsonKey(toJson: reportTypeToJson)
  final ReportType type;
  @JsonKey(toJson: reportPeriodToJson)
  final ReportPeriod period;
  @JsonKey(toJson: _dateTimeToJson)
  final DateTime? startDate;
  @JsonKey(toJson: _dateTimeToJson)
  final DateTime? endDate;
  final String? description;
  final Map<String, dynamic>? filterCriteria;
  final bool isScheduled;

  CreateReportRequestModel({
    required this.title,
    required this.type,
    required this.period,
    this.startDate,
    this.endDate,
    this.description,
    this.filterCriteria,
    this.isScheduled = false,
  });

  Map<String, dynamic> toJson() => _$CreateReportRequestModelToJson(this);
}

// Hızlı Rapor Request Modeli
@JsonSerializable(createFactory: false)
class QuickReportRequestModel {
  @JsonKey(toJson: reportTypeToJson)
  final ReportType type;
  @JsonKey(toJson: reportPeriodToJson)
  final ReportPeriod period;
  @JsonKey(toJson: _dateTimeToJson)
  final DateTime? startDate;
  @JsonKey(toJson: _dateTimeToJson)
  final DateTime? endDate;

  QuickReportRequestModel({
    required this.type,
    required this.period,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => _$QuickReportRequestModelToJson(this);

  // Query parametreleri için Map oluşturma
  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'type': reportTypeToJson(type).toString(),
      'period': reportPeriodToJson(period).toString(),
    };

    if (startDate != null) {
      params['startDate'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      params['endDate'] = endDate!.toIso8601String();
    }

    return params;
  }
}

// Rapor Export Request Modeli
@JsonSerializable(createFactory: false)
class ExportReportRequestModel {
  final int reportId;
  @JsonKey(toJson: reportFormatToJson)
  final ReportFormat format;

  ExportReportRequestModel({
    required this.reportId,
    required this.format,
  });

  Map<String, dynamic> toJson() => _$ExportReportRequestModelToJson(this);
}

// Rapor Filtreleme Modeli (Query parametreleri için)
class ReportFilterModel {
  final ReportType? type;
  final ReportPeriod? period;
  final DateTime? startDate;
  final DateTime? endDate;
  final int pageNumber;
  final int pageSize;

  ReportFilterModel({
    this.type,
    this.period,
    this.startDate,
    this.endDate,
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  // Query parametreleri için Map oluşturma
  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };

    if (type != null) {
      params['type'] = reportTypeToJson(type!).toString();
    }
    if (period != null) {
      params['period'] = reportPeriodToJson(period!).toString();
    }
    if (startDate != null) {
      params['startDate'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      params['endDate'] = endDate!.toIso8601String();
    }

    return params;
  }

  // Copy constructor
  ReportFilterModel copyWith({
    ReportType? type,
    ReportPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  }) {
    return ReportFilterModel(
      type: type ?? this.type,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
