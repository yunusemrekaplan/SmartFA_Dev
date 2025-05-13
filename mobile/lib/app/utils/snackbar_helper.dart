import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'error_handler.dart';

/// SmartFA uygulaması için genel snackbar mesajlarını yöneten yardımcı sınıf.
/// Başarı, hata, bilgi ve uyarı mesajlarını göstermek için kullanılır.
class SnackbarHelper {
  /// Başarı mesajı gösterir.
  /// [message] Gösterilecek mesaj.
  /// [title] Snackbar başlığı (isteğe bağlı).
  /// [duration] Snackbar'ın ekranda kalma süresi (varsayılan 3 saniye).
  static void showSuccess({
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 2000),
    SnackBarButton? mainButton,
  }) {
    Future.delayed(const Duration(milliseconds: 150), () {
      Get.snackbar(
        title ?? 'Başarılı',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: duration,
        icon: Icon(
          Icons.check_circle_outline,
          color: Get.theme.colorScheme.onPrimary,
        ),
        isDismissible: true,
        mainButton: mainButton != null
            ? TextButton.icon(
                onPressed: mainButton.onPressed,
                icon: Icon(
                  mainButton.icon ?? Icons.arrow_forward,
                  color: Get.theme.colorScheme.onPrimary,
                ),
                label: Text(
                  mainButton.label,
                  style: TextStyle(color: Get.theme.colorScheme.onPrimary),
                ),
              )
            : null,
      );
    });
  }

  /// Hata mesajı gösterir.
  /// [message] Gösterilecek mesaj.
  /// [title] Snackbar başlığı (isteğe bağlı).
  /// [duration] Snackbar'ın ekranda kalma süresi (varsayılan 3 saniye).
  static void showError({
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 2500),
    Icon? icon,
    SnackBarButton? mainButton,
  }) {
    Future.delayed(const Duration(milliseconds: 150), () {
      Get.snackbar(
        title ?? 'Hata',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: duration,
        icon: icon ??
            Icon(
              Icons.error_outline,
              color: Get.theme.colorScheme.onError,
            ),
        isDismissible: true,
        mainButton: mainButton != null
            ? TextButton.icon(
                onPressed: mainButton.onPressed,
                icon: Icon(
                  mainButton.icon ?? Icons.arrow_forward,
                  color: Get.theme.colorScheme.onError,
                ),
                label: Text(
                  mainButton.label,
                  style: TextStyle(color: Get.theme.colorScheme.onError),
                ),
              )
            : null,
      );
    });
  }

  /// Uyarı mesajı gösterir.
  /// [message] Gösterilecek mesaj.
  /// [title] Snackbar başlığı (isteğe bağlı).
  /// [duration] Snackbar'ın ekranda kalma süresi (varsayılan 3 saniye).
  static void showWarning({
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 1500),
    SnackBarButton? mainButton,
  }) {
    Future.delayed(const Duration(milliseconds: 150), () {
      Get.snackbar(
        title ?? 'Uyarı',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: duration,
        icon: const Icon(
          Icons.warning_amber_outlined,
          color: Colors.white,
        ),
        isDismissible: true,
        mainButton: mainButton != null
            ? TextButton.icon(
                onPressed: mainButton.onPressed,
                icon: Icon(
                  mainButton.icon ?? Icons.arrow_forward,
                  color: Colors.white,
                ),
                label: Text(
                  mainButton.label,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : null,
      );
    });
  }

  /// Bilgi mesajı gösterir.
  /// [message] Gösterilecek mesaj.
  /// [title] Snackbar başlığı (isteğe bağlı).
  /// [duration] Snackbar'ın ekranda kalma süresi (varsayılan 3 saniye).
  static void showInfo({
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 1500),
    SnackBarButton? mainButton,
  }) {
    Future.delayed(const Duration(milliseconds: 150), () {
      Get.snackbar(
        title ?? 'Bilgi',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: duration,
        icon: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
        isDismissible: true,
        mainButton: mainButton != null
            ? TextButton.icon(
                onPressed: mainButton.onPressed,
                icon: Icon(
                  mainButton.icon ?? Icons.arrow_forward,
                  color: Colors.white,
                ),
                label: Text(
                  mainButton.label,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : null,
      );
    });
  }
}
