import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/app/data/models/enums/account_type.dart';

part 'account_request_models.g.dart'; // json_serializable için

// --- Hesap Oluşturma Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class CreateAccountRequestModel {
  final String name;
  // JSON'a gönderirken enum'ın değerini (int) veya adını (string) gönderebiliriz.
  // Backend'in ne beklediğine göre ayarlanmalı. Genellikle int daha güvenilirdir.
  @JsonKey(toJson: accountTypeToInt) // Enum'ı int'e çevir
  final AccountType type;
  final String currency;
  final double initialBalance; // Dart'ta double

  CreateAccountRequestModel({
    required this.name,
    required this.type,
    required this.currency,
    required this.initialBalance,
  });

  Map<String, dynamic> toJson() => _$CreateAccountRequestModelToJson(this);
}

// --- Hesap Güncelleme Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class UpdateAccountRequestModel {
  final String name;

  UpdateAccountRequestModel({
    required this.name,
  });

  Map<String, dynamic> toJson() => _$UpdateAccountRequestModelToJson(this);
}

// AccountType enum'ını JSON'a gönderirken int değerine çeviren yardımcı fonksiyon
int _accountTypeToJson(AccountType type) => accountTypeToInt(type);

// Veya string olarak göndermek isterseniz:
// String _accountTypeToJsonString(AccountType type) => type.name; // Enum'ın adını kullanır
// Bu durumda CreateAccountRequestModel'deki JsonKey şöyle olurdu:
// @JsonKey(toJson: _accountTypeToJsonString)
