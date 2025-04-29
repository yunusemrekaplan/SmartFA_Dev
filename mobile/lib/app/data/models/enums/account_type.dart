import 'package:json_annotation/json_annotation.dart';

enum AccountType {
  // Backend'deki enum değerleriyle aynı sırada veya isimde olmalı
  // Veya JsonKey ile eşleştirme yapılmalı
  @JsonValue(1) // Backend'deki enum değeri (varsayım)
  Cash,
  @JsonValue(2)
  Bank,
  @JsonValue(3)
  CreditCard
}

AccountType accountTypeFromString(String typeString) {
  switch (typeString.toLowerCase()) {
    case 'cash':
      return AccountType.Cash;
    case 'bank': // Backend'den gelen string'e göre ayarla
      return AccountType.Bank;
    case 'creditcard':
      return AccountType.CreditCard;
    default:
    // Varsayılan bir değer veya hata fırlatma
      print("Uyarı: Bilinmeyen Hesap Türü String'i: $typeString");
      return AccountType.Cash; // Veya başka bir varsayılan
  }
}