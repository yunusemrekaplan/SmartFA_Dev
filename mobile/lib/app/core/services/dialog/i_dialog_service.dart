import 'package:flutter/material.dart';

/// Dialog işlemlerini tanımlayan arayüz
abstract class IDialogService {
  /// Onay dialogu gösterir
  Future<bool?> showConfirmation({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDanger,
    IconData? icon,
    VoidCallback? onConfirm,
  });

  /// Silme onay dialogu gösterir
  Future<bool?> showDeleteConfirmation({
    required String title,
    required String message,
    VoidCallback? onConfirm,
  });

  /// Bilgi dialogu gösterir
  Future<void> showInfo({
    required String title,
    required String message,
    String? buttonText,
  });

  /// Hata dialogu gösterir
  Future<void> showError({
    required String title,
    required String message,
    String? buttonText,
  });

  /// Form içeren dialog gösterir
  Future<T?> showForm<T>({
    required String title,
    required Widget formContent,
    String? confirmText,
    String? cancelText,
    Function(T?)? onConfirm,
  });

  /// Özel dialog gösterir
  Future<T?> showCustom<T>({
    required String title,
    required Widget content,
    required List<Widget> actions,
  });

  /// Çıkış onay dialogu gösterir
  Future<bool?> showLogoutConfirmation({
    required VoidCallback onConfirm,
  });

  /// Loading dialogu gösterir
  Future<void> showLoading({
    String? message,
  });

  /// En son dialogu kapatır
  void closeLastDialog();

  /// Tüm dialogları kapatır
  void closeAllDialogs();
}
