import 'package:json_annotation/json_annotation.dart';

part 'budget_request_models.g.dart'; // json_serializable için

// --- Bütçe Oluşturma Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class CreateBudgetRequestModel {
  final int categoryId;
  final double amount; // Dart'ta double
  final int month;
  final int year;

  CreateBudgetRequestModel({
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  });

  /// Nesneyi JSON map'ine dönüştürür.
  Map<String, dynamic> toJson() => _$CreateBudgetRequestModelToJson(this);
}

// --- Bütçe Güncelleme Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class UpdateBudgetRequestModel {
  final double amount; // Sadece tutar güncelleniyor

  UpdateBudgetRequestModel({
    required this.amount,
  });

  /// Nesneyi JSON map'ine dönüştürür.
  Map<String, dynamic> toJson() => _$UpdateBudgetRequestModelToJson(this);
}
