import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/core/services/snackbar/i_snackbar_service.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/utils/error_handler/auth_error_handler.dart';
import 'package:mobile/app/utils/error_handler/i_error_handler.dart';
import 'package:mobile/app/utils/error_handler/network_error_handler.dart';
import 'package:mobile/app/utils/error_handler/unexpected_error_handler.dart';
import 'package:mobile/app/utils/error_handler/validation_error_handler.dart';

/// Merkezi hata yöneticisi
class ErrorHandler {
  final _snackbarService = Get.find<ISnackbarService>();

  final List<IErrorHandler> _handlers = [
    AuthErrorHandler(),
    NetworkErrorHandler(),
    ValidationErrorHandler(),
    UnexpectedErrorHandler(),
  ];

  /// Verilen hatayı uygun handler ile işler
  void handleError(
    AppException error, {
    String? message,
    VoidCallback? onRetry,
    String? customTitle,
  }) {
    // Hata mesajı verilmemişse direkt exception'dan al
    final errorMessage = message ?? error.message;

    // Uygun handler'ı bul ve işle
    for (final handler in _handlers) {
      if (handler.canHandle(error)) {
        handler.handle(error, errorMessage,
            onRetry: onRetry, customTitle: customTitle);
        return;
      }
    }

    // Hiçbir handler bulunamazsa genel hata göster
    _snackbarService.showError(
      title: customTitle ?? 'Hata',
      message: errorMessage,
    );
  }
}
