import 'package:json_annotation/json_annotation.dart';

enum ReportFormat {
  @JsonValue(1)
  PDF,
  @JsonValue(2)
  Excel,
  @JsonValue(3)
  JSON,
  @JsonValue(4)
  CSV,
}

// Enum helper fonksiyonları
int reportFormatToJson(ReportFormat format) {
  switch (format) {
    case ReportFormat.PDF:
      return 1;
    case ReportFormat.Excel:
      return 2;
    case ReportFormat.JSON:
      return 3;
    case ReportFormat.CSV:
      return 4;
  }
}

ReportFormat reportFormatFromJson(int value) {
  switch (value) {
    case 1:
      return ReportFormat.PDF;
    case 2:
      return ReportFormat.Excel;
    case 3:
      return ReportFormat.JSON;
    case 4:
      return ReportFormat.CSV;
    default:
      throw ArgumentError('Invalid ReportFormat value: $value');
  }
}

// Extension for display names
extension ReportFormatExtension on ReportFormat {
  String get displayName {
    switch (this) {
      case ReportFormat.PDF:
        return 'PDF';
      case ReportFormat.Excel:
        return 'Excel';
      case ReportFormat.JSON:
        return 'JSON';
      case ReportFormat.CSV:
        return 'CSV';
    }
  }

  String get fileExtension {
    switch (this) {
      case ReportFormat.PDF:
        return 'pdf';
      case ReportFormat.Excel:
        return 'xlsx';
      case ReportFormat.JSON:
        return 'json';
      case ReportFormat.CSV:
        return 'csv';
    }
  }
}
