import 'package:flutter/material.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/auth_exception.dart';
import 'package:mobile/app/services/dialog_service.dart';
import 'package:mobile/app/utils/error_handler/i_error_handler.dart';

/// Kimlik doğrulama hatalarını işleyen handler
class AuthErrorHandler implements IErrorHandler {
  @override
  bool canHandle(AppException error) => error is AuthException && error.isTokenExpired;

  @override
  void handle(
    AppException error,
    String message, {
    VoidCallback? onRetry,
    String? customTitle,
  }) {
    if (error is AuthException) {
      // Login ekranına yönlendirme ErrorInterceptor'da yapılıyor
      // Burada sadece kullanıcıya bilgilendirme gösteriyoruz
      DialogService.showInfoDialog(
        title: customTitle ?? 'Oturum Sonlandı',
        message: message,
      );
    }
  }
}
