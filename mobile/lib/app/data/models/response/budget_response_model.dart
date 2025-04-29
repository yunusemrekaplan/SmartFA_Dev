import 'package:json_annotation/json_annotation.dart';

part 'budget_response_model.g.dart'; // json_serializable için

@JsonSerializable()
class BudgetModel {
  final int id;
  final int categoryId;
  final String categoryName; // Backend DTO'dan geliyor
  final String? categoryIcon; // Backend DTO'dan geliyor
  final double amount; // Bütçe limiti (Dart'ta double)
  final int month;
  final int year;
  final double spentAmount; // Backend DTO'dan geliyor (hesaplanmış)
  final double remainingAmount; // Backend DTO'dan geliyor (hesaplanmış)

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    required this.amount,
    required this.month,
    required this.year,
    required this.spentAmount,
    required this.remainingAmount,
  });

  /// JSON map'inden BudgetModel nesnesi oluşturur.
  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  /// BudgetModel nesnesini JSON map'ine dönüştürür.
  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);

  // Opsiyonel: Eşitlik ve hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BudgetModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              categoryId == other.categoryId &&
              categoryName == other.categoryName &&
              categoryIcon == other.categoryIcon &&
              amount == other.amount &&
              month == other.month &&
              year == other.year &&
              spentAmount == other.spentAmount &&
              remainingAmount == other.remainingAmount;

  @override
  int get hashCode =>
      id.hashCode ^
      categoryId.hashCode ^
      categoryName.hashCode ^
      categoryIcon.hashCode ^
      amount.hashCode ^
      month.hashCode ^
      year.hashCode ^
      spentAmount.hashCode ^
      remainingAmount.hashCode;

  @override
  String toString() {
    return 'BudgetModel(id: $id, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, amount: $amount, month: $month, year: $year, spentAmount: $spentAmount, remainingAmount: $remainingAmount)';
  }
}
