import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/core/services/dialog/i_dialog_service.dart';
import 'package:mobile/app/core/services/navigation/i_navigation_service.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

/// Dialog işlemlerini yöneten servis
class DialogService extends GetxService implements IDialogService {
  final INavigationService _navigationService;

  DialogService(this._navigationService);

  @override
  Future<bool?> showConfirmation({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDanger = false,
    IconData? icon,
    VoidCallback? onConfirm,
  }) async {
    final buttonColor = isDanger ? AppColors.error : AppColors.primary;

    return await _navigationService.showDialog<bool>(
      dialog: AlertDialog(
        title: Text(
          title,
          style: Get.theme.dialogTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText ?? 'İptal',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
              if (onConfirm != null) onConfirm();
            },
            style: TextButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText ?? (isDanger ? 'Sil' : 'Tamam')),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        ),
      ),
    );
  }

  @override
  Future<bool?> showDeleteConfirmation({
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) async {
    return showConfirmation(
      title: title,
      message: message,
      confirmText: 'Sil',
      cancelText: 'İptal',
      isDanger: true,
      icon: Icons.warning_amber_rounded,
      onConfirm: onConfirm,
    );
  }

  @override
  Future<void> showInfo({
    required String title,
    required String message,
    String? buttonText,
  }) async {
    await _navigationService.showDialog(
      dialog: AlertDialog(
        title: Text(
          title,
          style: Get.theme.dialogTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: Get.theme.dialogTheme.contentTextStyle,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(buttonText ?? 'Tamam'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        ),
      ),
    );
  }

  @override
  Future<void> showError({
    required String title,
    required String message,
    String? buttonText,
  }) async {
    await _navigationService.showDialog(
      dialog: AlertDialog(
        title: Text(
          title,
          style: Get.theme.dialogTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(buttonText ?? 'Tamam'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        ),
      ),
    );
  }

  @override
  Future<T?> showForm<T>({
    required String title,
    required Widget formContent,
    String? confirmText,
    String? cancelText,
    Function(T?)? onConfirm,
  }) async {
    T? result;

    await _navigationService.showDialog(
      dialog: AlertDialog(
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
            child: Text(cancelText ?? 'İptal'),
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
            child: Text(confirmText ?? 'Tamam'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        ),
      ),
    );

    return result;
  }

  @override
  Future<T?> showCustom<T>({
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) async {
    return await _navigationService.showDialog<T>(
      dialog: AlertDialog(
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

  @override
  Future<bool?> showLogoutConfirmation({
    required VoidCallback onConfirm,
  }) async {
    return await showConfirmation(
      title: 'Çıkış Yap',
      message: 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
      confirmText: 'Çıkış Yap',
      cancelText: 'İptal',
      isDanger: true,
      onConfirm: onConfirm,
    );
  }

  @override
  Future<void> showLoading({String? message}) async {
    await _navigationService.showDialog(
      dialog: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void closeLastDialog() {
    _navigationService.closeLastDialog();
  }

  @override
  void closeAllDialogs() {
    _navigationService.closeAllDialogs();
  }
}
