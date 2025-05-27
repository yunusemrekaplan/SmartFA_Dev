import 'package:flutter/material.dart';

/// Snackbar işlemlerini tanımlayan arayüz
abstract class ISnackbarService {
  /// Başarı snackbar'ı gösterir
  void showSuccess({
    required String message,
    String? title,
    Duration? duration,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  });

  /// Hata snackbar'ı gösterir
  void showError({
    required String message,
    String? title,
    Duration? duration,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  });

  /// Uyarı snackbar'ı gösterir
  void showWarning({
    required String message,
    String? title,
    Duration? duration,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  });

  /// Bilgi snackbar'ı gösterir
  void showInfo({
    required String message,
    String? title,
    Duration? duration,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  });

  void showNotImplemented();

  /// En son snackbar'ı kapatır
  void closeLastSnackbar();

  /// Tüm snackbar'ları kapatır
  void closeAllSnackbars();
}
