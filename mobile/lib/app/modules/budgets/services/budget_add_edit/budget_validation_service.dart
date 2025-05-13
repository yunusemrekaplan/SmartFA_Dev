import 'package:get/get.dart';

/// Bütçe doğrulama servisi - SRP (Single Responsibility) prensibi uygulandı
class BudgetValidationService {
  // Kategori doğrulama
  final RxBool showCategoryError = RxBool(false);

  /// Tutarı doğrula
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen bir tutar girin';
    }
    final cleanValue = value
        .replaceAll('₺', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    if (cleanValue.isEmpty) {
      return 'Lütfen bir tutar girin';
    }
    final amount = double.tryParse(cleanValue);
    if (amount == null || amount <= 0) {
      return 'Lütfen geçerli bir tutar girin';
    }
    return null;
  }

  /// Tutarı temizle
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

  /// Kategori seçilip seçilmediğini kontrol et
  bool validateCategory(int? categoryId) {
    if (categoryId == null) {
      showCategoryError.value = true;
      return false;
    }
    showCategoryError.value = false;
    return true;
  }

  /// Formu doğrula - tüm validasyon kurallarını uygular
  bool validateForm(int? categoryId, String? amount) {
    // Tüm doğrulama kuralları burada uygulanabilir
    return validateCategory(categoryId) && validateAmount(amount) == null;
  }
}
