import 'package:json_annotation/json_annotation.dart';

enum ReportPeriod {
  @JsonValue(1)
  Daily,
  @JsonValue(2)
  Weekly,
  @JsonValue(3)
  Monthly,
  @JsonValue(4)
  Quarterly,
  @JsonValue(5)
  Yearly,
  @JsonValue(6)
  Custom,
}

// Enum helper fonksiyonları
int reportPeriodToJson(ReportPeriod period) {
  switch (period) {
    case ReportPeriod.Daily:
      return 1;
    case ReportPeriod.Weekly:
      return 2;
    case ReportPeriod.Monthly:
      return 3;
    case ReportPeriod.Quarterly:
      return 4;
    case ReportPeriod.Yearly:
      return 5;
    case ReportPeriod.Custom:
      return 6;
  }
}

ReportPeriod reportPeriodFromJson(int value) {
  switch (value) {
    case 1:
      return ReportPeriod.Daily;
    case 2:
      return ReportPeriod.Weekly;
    case 3:
      return ReportPeriod.Monthly;
    case 4:
      return ReportPeriod.Quarterly;
    case 5:
      return ReportPeriod.Yearly;
    case 6:
      return ReportPeriod.Custom;
    default:
      throw ArgumentError('Invalid ReportPeriod value: $value');
  }
}

// Extension for display names
extension ReportPeriodExtension on ReportPeriod {
  String get displayName {
    switch (this) {
      case ReportPeriod.Daily:
        return 'Günlük';
      case ReportPeriod.Weekly:
        return 'Haftalık';
      case ReportPeriod.Monthly:
        return 'Aylık';
      case ReportPeriod.Quarterly:
        return 'Çeyreklik';
      case ReportPeriod.Yearly:
        return 'Yıllık';
      case ReportPeriod.Custom:
        return 'Özel';
    }
  }
}
