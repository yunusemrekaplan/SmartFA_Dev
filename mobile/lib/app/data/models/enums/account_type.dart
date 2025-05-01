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

AccountType accountTypeToEnum(int value) {
  switch (value) {
    case 1:
      return AccountType.Cash;
    case 2:
      return AccountType.Bank;
    case 3:
      return AccountType.CreditCard;
    default:
      throw Exception('Unknown account type value: $value');
  }
}

int accountTypeToInt(AccountType type) {
  switch (type) {
    case AccountType.Cash:
      return 1;
    case AccountType.Bank:
      return 2;
    case AccountType.CreditCard:
      return 3;
  }
}

String accountTypeToString(AccountType accountType) {
  switch (accountType) {
    case AccountType.Cash:
      return 'Nakit';
    case AccountType.Bank:
      return 'Banka';
    case AccountType.CreditCard:
      return 'Kredi Kartı';
  }
}
