import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'snackbar_helper.dart';

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
      Get.dialog(
        AlertDialog(
          title: Text(customTitle ?? 'Oturum Sonlandı'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Tamam'),
            ),
          ],
        ),
        barrierDismissible: false, // Kullanıcı dışarı tıklayarak kapatamamalı
      );
    }
  }
}

/// Ağ hatalarını işleyen handler
class NetworkErrorHandler implements IErrorHandler {
  @override
  bool canHandle(AppException error) => error is NetworkException;

  @override
  void handle(
    AppException error,
    String message, {
    VoidCallback? onRetry,
    String? customTitle,
  }) {
    if (error is NetworkException) {
      final title = _getNetworkErrorTitle(error, customTitle);
      final icon = _getNetworkErrorIcon(error.code);

      // İnternet bağlantısı ile ilgili hatalar için yeniden deneme butonu ekleyelim
      if (error.code == 'CONNECTION_ERROR' || error.code == 'TIMEOUT_ERROR') {
        SnackbarHelper.showError(
          title: title,
          message: message,
          icon: icon,
          duration: const Duration(seconds: 5),
          mainButton: onRetry != null
              ? SnackBarButton(
                  label: 'Tekrar Dene',
                  onPressed: onRetry,
                  icon: Icons.refresh,
                )
              : null,
        );
      } else {
        SnackbarHelper.showError(
          title: title,
          message: message,
          icon: icon,
        );
      }
    }
  }

  /// Hata koduna göre başlık belirler
  String _getNetworkErrorTitle(NetworkException error, String? customTitle) {
    if (customTitle != null) return customTitle;

    if (error.statusCode != null) {
      if (error.statusCode! >= 500) {
        return 'Sunucu Hatası';
      } else if (error.statusCode == 404) {
        return 'Bulunamadı';
      } else if (error.statusCode == 403) {
        return 'Yetkisiz Erişim';
      } else if (error.statusCode == 429) {
        return 'Çok Fazla İstek';
      }
    }

    if (error.code == 'CONNECTION_ERROR') {
      return 'Bağlantı Hatası';
    } else if (error.code == 'TIMEOUT_ERROR') {
      return 'Zaman Aşımı';
    }

    return 'Ağ Hatası';
  }

  /// Hata koduna göre ikon belirler
  Icon _getNetworkErrorIcon(String? errorCode) {
    switch (errorCode) {
      case 'CONNECTION_ERROR':
        return const Icon(Icons.wifi_off, color: Colors.white);
      case 'TIMEOUT_ERROR':
        return const Icon(Icons.timer_off, color: Colors.white);
      case 'HTTP_404':
        return const Icon(Icons.find_in_page, color: Colors.white);
      case 'HTTP_403':
        return const Icon(Icons.no_encryption, color: Colors.white);
      case 'HTTP_429':
        return const Icon(Icons.hourglass_full, color: Colors.white);
      default:
        return const Icon(Icons.error_outline, color: Colors.white);
    }
  }
}

/// Doğrulama hatalarını işleyen handler
class ValidationErrorHandler implements IErrorHandler {
  @override
  bool canHandle(AppException error) => error is ValidationException;

  @override
  void handle(
    AppException error,
    String message, {
    VoidCallback? onRetry,
    String? customTitle,
  }) {
    if (error is ValidationException) {
      final title = customTitle ?? 'Geçersiz Bilgi';

      // Alan hatalarını güzel bir şekilde formatla
      if (error.fieldErrors != null && error.fieldErrors!.isNotEmpty) {
        final errorMessages = _formatFieldErrors(error.fieldErrors!);

        if (errorMessages.length <= 3) {
          // 3 veya daha az hata varsa direkt snackbar ile göster
          SnackbarHelper.showError(
            title: title,
            message: errorMessages.join('\n'),
          );
        } else {
          // Çok fazla hata varsa dialog ile göster
          Get.dialog(
            AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: errorMessages
                      .map((msg) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(child: Text(msg)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Tamam'),
                ),
              ],
            ),
          );
        }
      } else {
        // Sadece genel hata mesajı varsa
        SnackbarHelper.showError(
          title: title,
          message: message,
        );
      }
    }
  }

  /// Hata alanlarını okunabilir mesajlara dönüştürür
  List<String> _formatFieldErrors(Map<String, String> fieldErrors) {
    return fieldErrors.entries.map((entry) {
      final fieldName = _getReadableFieldName(entry.key);
      return '$fieldName: ${entry.value}';
    }).toList();
  }

  /// Alan adlarını daha okunabilir hale getirir
  String _getReadableFieldName(String fieldName) {
    final Map<String, String> fieldNameMap = {
      'email': 'E-posta',
      'password': 'Şifre',
      'firstName': 'Ad',
      'lastName': 'Soyad',
      'username': 'Kullanıcı Adı',
      'phoneNumber': 'Telefon',
      'address': 'Adres',
      'birthDate': 'Doğum Tarihi',
      'amount': 'Tutar',
      'date': 'Tarih',
      'description': 'Açıklama',
      'name': 'İsim',
      'title': 'Başlık',
      'content': 'İçerik',
    };

    if (fieldNameMap.containsKey(fieldName)) {
      return fieldNameMap[fieldName]!;
    }

    if (fieldName.contains('_')) {
      return fieldName
          .split('_')
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');
    } else {
      String result = fieldName.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => ' ${match.group(0)}',
      );
      return result.isNotEmpty ? result[0].toUpperCase() + result.substring(1) : result;
    }
  }
}

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
        handler.handle(error, errorMessage, onRetry: onRetry, customTitle: customTitle);
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

/// Snackbar içinde gösterilecek buton
class SnackBarButton {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  SnackBarButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });
}
