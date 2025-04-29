import 'package:json_annotation/json_annotation.dart';

part 'debt_request_models.g.dart'; // json_serializable için

// --- Borç Oluşturma Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class CreateDebtRequestModel {
  final String name;
  final String? lenderName;
  final double totalAmount; // Dart'ta double
  final double remainingAmount; // Dart'ta double
  final String currency;

  CreateDebtRequestModel({
    required this.name,
    this.lenderName,
    required this.totalAmount,
    required this.remainingAmount,
    required this.currency,
  });

  /// Nesneyi JSON map'ine dönüştürür.
  Map<String, dynamic> toJson() => _$CreateDebtRequestModelToJson(this);
}

// --- Borç Güncelleme Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class UpdateDebtRequestModel {
  final String name;
  final String? lenderName;

  UpdateDebtRequestModel({
    required this.name,
    this.lenderName,
  });

  /// Nesneyi JSON map'ine dönüştürür.
  Map<String, dynamic> toJson() => _$UpdateDebtRequestModelToJson(this);
}
