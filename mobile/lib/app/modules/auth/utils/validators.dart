import 'package:get/get.dart';

/// Form doğrulama işlemleri için yardımcı sınıf
class AuthValidators {
  /// E-posta doğrulama
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta boş olamaz.';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Geçerli bir e-posta giriniz.';
    }
    return null;
  }

  /// Şifre doğrulama
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş olamaz.';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    return null;
  }

  /// Şifre tekrarı doğrulama
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı boş olamaz.';
    }
    if (value != password) {
      return 'Şifreler eşleşmiyor.';
    }
    return null;
  }
}
