import 'package:flutter/material.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/utils/error_handler/i_error_handler.dart';
import 'package:mobile/app/utils/snackbar_helper.dart';

/// Beklenmeyen hataları işleyen handler
class UnexpectedErrorHandler implements IErrorHandler {
  @override
  bool canHandle(AppException error) => error is UnexpectedException;

  @override
  void handle(
    AppException error,
    String message, {
    VoidCallback? onRetry,
    String? customTitle,
  }) {
    SnackbarHelper.showError(
      title: customTitle ?? 'Beklenmeyen Hata',
      message: message,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
    );
  }
}
