import 'package:json_annotation/json_annotation.dart';

part 'debt_response_model.g.dart'; // json_serializable için

@JsonSerializable()
class DebtModel {
  final int id;
  final String name;
  final String? lenderName; // Alacaklı adı (nullable)
  final double totalAmount; // Dart'ta double
  final double remainingAmount; // Dart'ta double
  final String currency;
  final bool isPaidOff; // Tamamen ödendi mi?

  DebtModel({
    required this.id,
    required this.name,
    this.lenderName,
    required this.totalAmount,
    required this.remainingAmount,
    required this.currency,
    required this.isPaidOff,
  });

  /// JSON map'inden DebtModel nesnesi oluşturur.
  factory DebtModel.fromJson(Map<String, dynamic> json) =>
      _$DebtModelFromJson(json);

  /// DebtModel nesnesini JSON map'ine dönüştürür.
  Map<String, dynamic> toJson() => _$DebtModelToJson(this);

  // Opsiyonel: Eşitlik ve hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DebtModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              lenderName == other.lenderName &&
              totalAmount == other.totalAmount &&
              remainingAmount == other.remainingAmount &&
              currency == other.currency &&
              isPaidOff == other.isPaidOff;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      lenderName.hashCode ^
      totalAmount.hashCode ^
      remainingAmount.hashCode ^
      currency.hashCode ^
      isPaidOff.hashCode;

  @override
  String toString() {
    return 'DebtModel(id: $id, name: $name, lenderName: $lenderName, totalAmount: $totalAmount, remainingAmount: $remainingAmount, currency: $currency, isPaidOff: $isPaidOff)';
  }
}
