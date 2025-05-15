import 'package:flutter/material.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/error_handler/auth_error_handler.dart';
import 'package:mobile/app/utils/error_handler/i_error_handler.dart';
import 'package:mobile/app/utils/error_handler/network_error_handler.dart';
import 'package:mobile/app/utils/error_handler/unexpected_error_handler.dart';
import 'package:mobile/app/utils/error_handler/validation_error_handler.dart';
import '../snackbar_helper.dart';

/// Merkezi hata yöneticisi
class ErrorHandler {
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
    SnackbarHelper.showError(
      title: customTitle ?? 'Hata',
      message: errorMessage,
    );
  }
}
