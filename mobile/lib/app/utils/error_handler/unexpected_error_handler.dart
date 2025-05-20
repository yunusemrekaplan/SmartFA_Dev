import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/core/services/snackbar/i_snackbar_service.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/utils/error_handler/i_error_handler.dart';

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
    Get.find<ISnackbarService>().showError(
      title: customTitle ?? 'Beklenmeyen Hata',
      message: message,
      icon: Icons.warning_amber_rounded,
    );
  }
}
