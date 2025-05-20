import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Temel navigasyon işlemlerini tanımlayan arayüz
abstract class INavigationService {
  /// Aktif snackbar'ları döndürür
  List<SnackbarController> get activeSnackbars;

  /// Aktif dialogları döndürür
  List<Widget> get activeDialogs;

  /// Aktif sayfaları döndürür
  List<String> get activePages;

  /// Snackbar gösterir
  void showSnackbar({
    required String title,
    required String message,
    Color backgroundColor,
    Color textColor,
    Duration duration,
    SnackPosition position,
  });

  /// Dialog gösterir
  Future<T?> showDialog<T>({
    required Widget dialog,
    bool barrierDismissible,
  });

  /// Yeni sayfa açar
  Future<T?> toNamed<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  });

  /// En son açık olan snackbar'ı kapatır
  void closeLastSnackbar();

  /// En son açık olan dialogu kapatır
  void closeLastDialog();

  /// En son açık olan sayfayı kapatır
  void closeLastPage();

  /// Tüm snackbar'ları kapatır
  void closeAllSnackbars();

  /// Tüm dialogları kapatır
  void closeAllDialogs();

  /// Tüm sayfaları kapatır (root hariç)
  void closeAllPages();

  /// Tüm açık pencereleri kapatır
  void closeAll();
}
