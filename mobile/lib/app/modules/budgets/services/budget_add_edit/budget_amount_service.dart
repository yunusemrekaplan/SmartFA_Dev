import 'package:get/get.dart';

/// Bütçe tutarı yönetim servisi - SRP (Single Responsibility) prensibi
class BudgetAmountService {
  // Tutar verisi
  final amount = RxDouble(0.0);

  BudgetAmountService();

  /// Tutarı belirli bir değere ayarlar
  void setAmount(double value) {
    if (value >= 0) {
      amount.value = value;
    }
  }

  /// Tutarı artırır
  void increaseAmount(double value) {
    if (value > 0) {
      amount.value += value;
    }
  }

  /// Tutarı azaltır
  void decreaseAmount(double value) {
    if (value > 0 && amount.value >= value) {
      amount.value -= value;
    }
  }

  /// Tutar formatlamayı temizler ve double değere çevirir
  double parseAmount(String value) {
    final cleanValue = value
        .replaceAll('₺', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    if (cleanValue.isNotEmpty) {
      final parsedValue = double.tryParse(cleanValue);
      if (parsedValue != null) {
        return parsedValue;
      }
    }
    return 0.0;
  }

  /// Tutarı formatlar
  String formatAmount() {
    return amount.value.toStringAsFixed(2).replaceAll('.', ',');
  }

  /// Tutarı para birimi ile formatlar
  String formatAmountWithCurrency() {
    return '₺${formatAmount()}';
  }

  /// Mevcut tutarı alır
  double getAmount() => amount.value;
}
