import 'package:flutter/material.dart';
import 'package:mobile/app/data/network/exceptions.dart';

/// Hata yönetimini sağlayan arayüz
abstract class IErrorHandler {
  /// Bu handler'ın verilen hata tipini işleyebilip işleyemeyeceğini kontrol eder
  bool canHandle(AppException error);

  /// Hatayı işler ve kullanıcıya gerekli bildirimleri gösterir
  void handle(
    AppException error,
    String message, {
    VoidCallback? onRetry,
    String? customTitle,
  });
}
