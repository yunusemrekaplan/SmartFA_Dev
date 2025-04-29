import 'package:json_annotation/json_annotation.dart';

part 'account_response_model.g.dart'; // json_serializable için

@JsonSerializable()
class AccountModel {
  final int id;
  final String name;
  // Backend'den 'Type' string olarak geliyor (AccountDto'da öyle tanımladık)
  final String type;
  final String currency;
  // Backend'den 'CurrentBalance' olarak geliyor (AccountDto'da öyle tanımladık)
  final double currentBalance; // Dart'ta genellikle double kullanılır

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.currentBalance,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);

  // Opsiyonel: Eşitlik ve hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AccountModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              type == other.type &&
              currency == other.currency &&
              currentBalance == other.currentBalance;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      currency.hashCode ^
      currentBalance.hashCode;

  @override
  String toString() {
    return 'AccountModel(id: $id, name: $name, type: $type, currency: $currency, currentBalance: $currentBalance)';
  }
}
