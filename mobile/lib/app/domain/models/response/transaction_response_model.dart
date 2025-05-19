import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';

part 'transaction_response_model.g.dart'; // json_serializable için

@JsonSerializable()
class TransactionModel {
  final int id;
  final int accountId;
  final String accountName;
  final int categoryId;
  final String categoryName;
  final String? categoryIcon;

  // Backend DTO'sunda CategoryType enum olarak tanımlı,
  // JSON'da int (0 veya 1) veya string ("Gider", "Gelir") olarak gelebilir.
  // json_serializable'ın bunu handle etmesi için enum'ı kullanıyoruz.
  final CategoryType categoryType;
  final double amount; // Dart'ta double
  final DateTime transactionDate; // DateTime olarak alıyoruz
  final String? notes;

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.accountName,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    required this.categoryType,
    required this.amount,
    required this.transactionDate,
    this.notes,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  // Opsiyonel: Eşitlik ve hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          accountId == other.accountId &&
          accountName == other.accountName &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          categoryIcon == other.categoryIcon &&
          categoryType == other.categoryType &&
          amount == other.amount &&
          transactionDate == other.transactionDate &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      accountId.hashCode ^
      accountName.hashCode ^
      categoryId.hashCode ^
      categoryName.hashCode ^
      categoryIcon.hashCode ^
      categoryType.hashCode ^
      amount.hashCode ^
      transactionDate.hashCode ^
      notes.hashCode;

  @override
  String toString() {
    return 'TransactionModel(id: $id, accountId: $accountId, accountName: $accountName, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryType: $categoryType, amount: $amount, transactionDate: $transactionDate, notes: $notes)';
  }
}
