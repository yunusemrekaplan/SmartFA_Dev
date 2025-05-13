import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Auth modülündeki UI işlemlerini yöneten servis
/// SRP (Single Responsibility Principle) - UI işlemleri tek bir sınıfta toplanır
class AuthUIService {
  /// Özellik henüz uygulanmadı mesajını gösterir
  void showFeatureNotImplementedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Bu özellik henüz uygulanmadı'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.info,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Başarılı giriş mesajını gösterir
  void showLoginSuccessMessage(String? userName) {
    Get.snackbar(
      'Giriş Başarılı',
      'Hoş geldiniz ${userName ?? ''}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Başarılı kayıt mesajını gösterir
  void showRegisterSuccessMessage() {
    Get.snackbar(
      'Kayıt Başarılı',
      'Kayıt işleminiz başarıyla tamamlandı.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Hata mesajını gösterir
  void showErrorMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  /// Şifre sıfırlama işlemi için onay dialogu gösterir
  Future<String?> showPasswordResetDialog(BuildContext context) async {
    final emailController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şifre Sıfırlama'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Şifre sıfırlama bağlantısı için e-posta adresinizi girin:'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresi',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(emailController.text.trim()),
              child: const Text('Sıfırlama Bağlantısı Gönder'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 24,
        );
      },
    );
  }
}
