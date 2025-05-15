import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

/// Tüm uygulama genelinde dialog gösterimini standartize eden servis sınıfı.
/// Bu sınıf, farklı dialog türlerini tutarlı bir şekilde göstermek için kullanılır.
class DialogService {
  /// Onay dialogu gösterir
  /// [title] Dialog başlığı
  /// [message] Dialog mesajı
  /// [confirmText] Onay butonu metni (varsayılan: "Tamam")
  /// [cancelText] İptal butonu metni (varsayılan: "İptal")
  /// [isDanger] Tehlikeli bir işlem için onay alınıyorsa true (varsayılan: false)
  /// [icon] Opsiyonel ikon
  /// [onConfirm] Onay butonuna basıldığında çalıştırılacak fonksiyon
  static Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDanger = false,
    IconData? icon,
    VoidCallback? onConfirm,
  }) async {
    final buttonColor = isDanger ? AppColors.error : AppColors.primary;

    return await Get.defaultDialog<bool>(
      title: title,
      titleStyle: Get.theme.dialogTheme.titleTextStyle?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDanger ? AppColors.warning : buttonColor,
              size: 48,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: Get.theme.dialogTheme.contentTextStyle,
          ),
        ],
      ),
      textConfirm: confirmText ?? (isDanger ? "Sil" : "Tamam"),
      confirmTextColor: Colors.white,
      buttonColor: buttonColor,
      textCancel: cancelText ?? "İptal",
      cancelTextColor: AppColors.textPrimary,
      onConfirm: () {
        Get.back(result: true);
        if (onConfirm != null) onConfirm();
      },
      radius: AppTheme.kBorderRadius,
      barrierDismissible: false,
    );
  }

  /// Silme onay dialogu gösterir
  /// [title] Dialog başlığı
  /// [message] Dialog mesajı
  /// [onConfirm] Onay butonuna basıldığında çalıştırılacak fonksiyon
  static Future<bool?> showDeleteConfirmationDialog({
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) async {
    return await showConfirmationDialog(
      title: title,
      message: message,
      confirmText: "Sil",
      cancelText: "İptal",
      isDanger: true,
      icon: Icons.warning_amber_rounded,
      onConfirm: onConfirm,
    );
  }

  /// Bilgi dialogu gösterir
  /// [title] Dialog başlığı
  /// [message] Dialog mesajı
  /// [buttonText] Buton metni (varsayılan: "Tamam")
  static Future<void> showInfoDialog({
    required String title,
    required String message,
    String? buttonText,
  }) async {
    await Get.defaultDialog(
      title: title,
      titleStyle: Get.theme.dialogTheme.titleTextStyle?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: Get.theme.dialogTheme.contentTextStyle,
      ),
      textConfirm: buttonText ?? "Tamam",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      radius: AppTheme.kBorderRadius,
      barrierDismissible: false,
    );
  }

  /// Hata dialogu gösterir
  /// [title] Dialog başlığı
  /// [message] Dialog mesajı
  /// [buttonText] Buton metni (varsayılan: "Tamam")
  static Future<void> showErrorDialog({
    required String title,
    required String message,
    String? buttonText,
  }) async {
    await Get.defaultDialog(
      title: title,
      titleStyle: Get.theme.dialogTheme.titleTextStyle?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.error,
      ),
      content: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Get.theme.dialogTheme.contentTextStyle,
          ),
        ],
      ),
      textConfirm: buttonText ?? "Tamam",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      radius: AppTheme.kBorderRadius,
      barrierDismissible: false,
    );
  }

  /// Form içeren dialog gösterir
  /// [title] Dialog başlığı
  /// [formContent] Form içeriği
  /// [confirmText] Onay butonu metni (varsayılan: "Tamam")
  /// [cancelText] İptal butonu metni (varsayılan: "İptal")
  /// [onConfirm] Onay butonuna basıldığında çalıştırılacak fonksiyon
  static Future<T?> showFormDialog<T>({
    required String title,
    required Widget formContent,
    String? confirmText,
    String? cancelText,
    Function(T?)? onConfirm,
  }) async {
    T? result;

    await Get.dialog(
      AlertDialog(
        title: Text(
          title,
          style: Get.theme.dialogTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: formContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(cancelText ?? "İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: result);
              if (onConfirm != null) onConfirm(result);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText ?? "Tamam"),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        ),
      ),
      barrierDismissible: false,
    );

    return result;
  }

  /// Özel dialog gösterir
  /// [title] Dialog başlığı
  /// [content] Dialog içeriği
  /// [actions] Dialog butonları
  static Future<T?> showCustomDialog<T>({
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) async {
    return await Get.dialog<T>(
      AlertDialog(
        title: Text(
          title,
          style: Get.theme.dialogTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: content,
        actions: actions,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        ),
      ),
    );
  }

  /// Çıkış onay dialogu gösterir
  static Future<bool?> showLogoutConfirmationDialog({
    required VoidCallback onConfirm,
  }) async {
    return await showConfirmationDialog(
      title: "Çıkış Yap",
      message: "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
      confirmText: "Çıkış Yap",
      cancelText: "İptal",
      isDanger: true,
      onConfirm: onConfirm,
    );
  }
}
