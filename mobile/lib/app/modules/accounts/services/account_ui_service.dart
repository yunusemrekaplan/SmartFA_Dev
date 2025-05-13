import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Hesaplar modülündeki UI işlemlerini yöneten servis
/// SRP (Single Responsibility Principle) - UI işlemleri tek bir sınıfta toplanır
class AccountUIService {
  /// Hesap silme onay dialogunu gösterir
  Future<bool?> showDeleteConfirmation(AccountModel account) async {
    return await Get.defaultDialog<bool>(
      title: "Hesabı Sil",
      titleStyle: Get.theme.dialogTheme.titleTextStyle?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "'${account.name}' hesabını silmek istediğinizden emin misiniz?",
            textAlign: TextAlign.center,
            style: Get.theme.dialogTheme.contentTextStyle,
          ),
          const SizedBox(height: 8),
          Text(
            "Bu işlem geri alınamaz ve hesaba bağlı tüm işlemler etkilenebilir.",
            textAlign: TextAlign.center,
            style: Get.theme.dialogTheme.contentTextStyle?.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      textConfirm: "Sil",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      textCancel: "İptal",
      cancelTextColor: AppColors.textPrimary,
      onConfirm: () {
        Get.back(result: true);
      },
      radius: 16,
    );
  }

  /// Genel onay dialogu gösterir
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    return await Get.defaultDialog<bool>(
      title: title,
      titleStyle: Get.theme.dialogTheme.titleTextStyle?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: Get.theme.dialogTheme.contentTextStyle,
      ),
      textConfirm: confirmText ?? "Evet",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      textCancel: cancelText ?? "İptal",
      cancelTextColor: AppColors.textPrimary,
      onConfirm: () {
        Get.back(result: true);
      },
      radius: 16,
    );
  }
}
