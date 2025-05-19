import 'package:json_annotation/json_annotation.dart';

part 'debt_payment_response_model.g.dart'; // json_serializable için

@JsonSerializable()
class DebtPaymentModel {
  final int id;
  final int debtId; // İlişkili borcun ID'si
  final double amount; // Dart'ta double
  final DateTime paymentDate; // ISO 8601 string'den DateTime'a
  final String? notes;

  DebtPaymentModel({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    this.notes,
  });

  /// JSON map'inden DebtPaymentModel nesnesi oluşturur.
  factory DebtPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$DebtPaymentModelFromJson(json);

  /// DebtPaymentModel nesnesini JSON map'ine dönüştürür.
  Map<String, dynamic> toJson() => _$DebtPaymentModelToJson(this);

  // Opsiyonel: Eşitlik ve hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DebtPaymentModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              debtId == other.debtId &&
              amount == other.amount &&
              paymentDate == other.paymentDate &&
              notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      debtId.hashCode ^
      amount.hashCode ^
      paymentDate.hashCode ^
      notes.hashCode;

  @override
  String toString() {
    return 'DebtPaymentModel(id: $id, debtId: $debtId, amount: $amount, paymentDate: $paymentDate, notes: $notes)';
  }
}

