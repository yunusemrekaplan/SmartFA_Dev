import 'package:flutter/material.dart';
import 'package:mobile/app/core/services/navigation/i_navigation_service.dart';
import 'package:mobile/app/core/services/snackbar/i_snackbar_service.dart';
import 'package:get/get.dart';

/// Snackbar işlemlerini yöneten servis
class SnackbarService extends GetxService implements ISnackbarService {
  final INavigationService _navigationService;

  SnackbarService(this._navigationService);

  @override
  void showSuccess({
    required String message,
    String? title,
    Duration? duration,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _navigationService.showSnackbar(
      title: title ?? 'Başarılı',
      message: message,
      backgroundColor: Get.theme.colorScheme.primary,
      textColor: Get.theme.colorScheme.onPrimary,
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  @override
  void showError({
    required String message,
    String? title,
    Duration? duration,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _navigationService.showSnackbar(
      title: title ?? 'Hata',
      message: message,
      backgroundColor: Get.theme.colorScheme.error,
      textColor: Get.theme.colorScheme.onError,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  @override
  void showWarning({
    required String message,
    String? title,
    Duration? duration,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _navigationService.showSnackbar(
      title: title ?? 'Uyarı',
      message: message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  @override
  void showInfo({
    required String message,
    String? title,
    Duration? duration,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _navigationService.showSnackbar(
      title: title ?? 'Bilgi',
      message: message,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  @override
  void showNotImplemented() {
    _navigationService.showSnackbar(
      title: 'Hata',
      message: 'Bu işlem henüz yapım aşamasındadır.',
    );
  }

  @override
  void closeLastSnackbar() {
    _navigationService.closeLastSnackbar();
  }

  @override
  void closeAllSnackbars() {
    _navigationService.closeAllSnackbars();
  }
}
