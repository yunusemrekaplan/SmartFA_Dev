import 'package:json_annotation/json_annotation.dart';

part 'debt_payment_request_models.g.dart'; // json_serializable için

// DateTime'ı ISO 8601 formatında string'e çeviren yardımcı fonksiyon
// (transaction_request_models.dart içinde de vardı, ortak bir yere taşınabilir)
String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();

// --- Borç Ödemesi Oluşturma Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class CreateDebtPaymentRequestModel {
  final int debtId;
  final double amount; // Dart'ta double
  @JsonKey(toJson: _dateTimeToJson)
  final DateTime paymentDate;
  final String? notes;

  CreateDebtPaymentRequestModel({
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    this.notes,
  });

  /// Nesneyi JSON map'ine dönüştürür.
  Map<String, dynamic> toJson() => _$CreateDebtPaymentRequestModelToJson(this);
}
