import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'exceptions.dart';

/// Uygulama genelinde hata yönetimini merkezi olarak sağlayan servis.
/// Farklı hata tiplerini uygun şekilde işler ve kullanıcıya gösterir.
class ErrorHandler {
  /// Singleton pattern
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// AppException'dan uygun hata yanıtı oluşturur ve gösterir
  void handleError(
    AppException error, {
    VoidCallback? onRetry,
    bool showSnackbar = true,
    String? customTitle,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    // Hata tipine göre özel işleme
    if (error is AuthException && error.isTokenExpired) {
      _handleAuthError(error);
      return;
    }

    if (error is NetworkException) {
      _handleNetworkError(error,
          onRetry: onRetry,
          showSnackbar: showSnackbar,
          customTitle: customTitle,
          snackPosition: snackPosition);
      return;
    }

    if (error is ValidationException) {
      _handleValidationError(error,
          showSnackbar: showSnackbar,
          customTitle: customTitle,
          snackPosition: snackPosition);
      return;
    }

    // Diğer hata tipleri için genel davranış
    if (showSnackbar) {
      Get.snackbar(
        customTitle ?? 'Hata',
        error.message,
        snackPosition: snackPosition,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        isDismissible: true,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  /// Bir Result nesnesinden hatayı yakalar ve işler
  void handleErrorFromResult<T, E extends AppException>(
    dynamic result, {
    VoidCallback? onRetry,
    bool showSnackbar = true,
    String? customTitle,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    if (result.isFailure) {
      final error = result.error;
      if (error is AppException) {
        handleError(
          error,
          onRetry: onRetry,
          showSnackbar: showSnackbar,
          customTitle: customTitle,
          snackPosition: snackPosition,
        );
      }
    }
  }

  /// Kimlik doğrulama hatalarını ele alır (örn. token süresi doldu)
  void _handleAuthError(AuthException error) {
    // Kullanıcı oturumunu sonlandır ve giriş ekranına yönlendir
    Get.offAllNamed(AppRoutes.LOGIN);

    // Opsiyonel: Özel dialog göster (daha nazik bir UX için)
    Get.dialog(
      AlertDialog(
        title: const Text('Oturum Sonlandı'),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Ağ hatalarını ele alır
  void _handleNetworkError(
    NetworkException error, {
    VoidCallback? onRetry,
    bool showSnackbar = true,
    String? customTitle,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    if (!showSnackbar) return;

    // Sunucudan gelen hata detaylarına göre başlık belirle
    String title = customTitle ?? 'Hata';
    if (error.statusCode != null) {
      if (error.statusCode! >= 500) {
        title = 'Sunucu Hatası';
      } else if (error.statusCode == 404) {
        title = 'Bulunamadı';
      } else if (error.statusCode == 403) {
        title = 'Yetkisiz Erişim';
      } else if (error.statusCode == 429) {
        title = 'Çok Fazla İstek';
      } else if (error.code == 'CONNECTION_ERROR' ||
          error.code == 'TIMEOUT_ERROR') {
        title = 'Bağlantı Hatası';
      }
    }

    // Aksiyon için retry butonu göster
    Get.snackbar(
      title,
      error.message, // Sunucudan gelen detaylı hata mesajı
      snackPosition: snackPosition,
      backgroundColor: Colors.orange.shade800,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      icon: _getIconForError(error.code),
      mainButton: onRetry != null
          ? TextButton(
              onPressed: onRetry,
              child: const Text(
                'Tekrar Dene',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  /// Doğrulama (validasyon) hatalarını ele alır
  void _handleValidationError(
    ValidationException error, {
    bool showSnackbar = true,
    String? customTitle,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    if (!showSnackbar) return;

    // Genel mesaj için başlık
    final title = customTitle ?? 'Geçersiz Bilgi';

    // Alan hatalarını içeren mesaj oluştur
    String message = error.message;
    if (error.fieldErrors != null && error.fieldErrors!.isNotEmpty) {
      // Daha detaylı bir hata göstermek için alanları listele
      final List<String> errorMessages = [];
      error.fieldErrors!.forEach((field, errorMsg) {
        // Alan adını daha okunabilir hale getir (örn: firstName -> Ad)
        String readableField = _getReadableFieldName(field);
        errorMessages.add('$readableField: $errorMsg');
      });

      // Eğer fieldErrors'dan gelen mesajlar varsa, genel mesajı değiştir
      if (errorMessages.isNotEmpty) {
        // En fazla 3 hata mesajı göster, fazlası varsa "..." ekle
        if (errorMessages.length > 3) {
          message = '${errorMessages.sublist(0, 3).join('\n')}\n...';
        } else {
          message = errorMessages.join('\n');
        }
      }
    }

    // Validasyon hatası gösterimi
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
    );

    // Ayrıntılı validasyon hatası varsa (alan bazlı),
    // ekranda form alanlarına bu hatalar gösterilecek şekilde Controller'a da bildirilmeli
    // Bu fonksiyonu çağıran controller, fieldErrors'u ilgili form alanlarına bağlayabilir
  }

  /// Hata koduna göre uygun simgeyi döndürür
  Icon _getIconForError(String? errorCode) {
    switch (errorCode) {
      case 'CONNECTION_ERROR':
        return const Icon(Icons.wifi_off, color: Colors.white);
      case 'TIMEOUT_ERROR':
        return const Icon(Icons.timer_off, color: Colors.white);
      case 'AUTH_ERROR':
      case 'TOKEN_EXPIRED':
        return const Icon(Icons.lock, color: Colors.white);
      case 'VALIDATION_ERROR':
        return const Icon(Icons.warning_amber_rounded, color: Colors.white);
      case 'NOT_FOUND':
        return const Icon(Icons.search_off, color: Colors.white);
      default:
        return const Icon(Icons.error_outline, color: Colors.white);
    }
  }

  /// Alan adlarını okunabilir hale getirir
  String _getReadableFieldName(String fieldName) {
    // CamelCase veya snake_case alan adlarını okunaklı metne dönüştür
    // Örn: firstName -> Ad, last_name -> Soyad, email -> E-posta

    // Özel maplemeler
    final Map<String, String> fieldNameMap = {
      'email': 'E-posta',
      'password': 'Şifre',
      'firstName': 'Ad',
      'first_name': 'Ad',
      'lastName': 'Soyad',
      'last_name': 'Soyad',
      'phoneNumber': 'Telefon',
      'phone_number': 'Telefon',
      'address': 'Adres',
      'birthDate': 'Doğum Tarihi',
      'birth_date': 'Doğum Tarihi',
      'username': 'Kullanıcı Adı',
      'confirmPassword': 'Şifre Tekrarı',
      'confirm_password': 'Şifre Tekrarı',
      'currentPassword': 'Mevcut Şifre',
      'current_password': 'Mevcut Şifre',
      'newPassword': 'Yeni Şifre',
      'new_password': 'Yeni Şifre',
      // Diğer alan adlarını buraya ekleyebilirsiniz
    };

    // Özel mapleme varsa kullan
    if (fieldNameMap.containsKey(fieldName)) {
      return fieldNameMap[fieldName]!;
    }

    // Özel mapleme yoksa, alan adını okunaklı hale getir
    if (fieldName.contains('_')) {
      // snake_case
      return fieldName
          .split('_')
          .map((word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');
    } else {
      // camelCase
      // Alan adındaki büyük harflerin önüne boşluk ekle ve ilk harfi büyüt
      String result = fieldName.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => ' ${match.group(0)}',
      );
      if (result.isNotEmpty) {
        result = result[0].toUpperCase() + result.substring(1);
      }
      return result;
    }
  }

  /// Beklenmeyen hataları ele alır ve loglar
  void handleUnexpectedError(
    dynamic error, {
    bool showSnackbar = true,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    // Hata logla
    debugPrint('UNEXPECTED ERROR: $error');

    // Exception'a dönüştür
    final appException = error is Exception
        ? UnexpectedException.fromException(error)
        : UnexpectedException(
            message: 'Beklenmeyen bir hata oluştu',
            details: error,
          );

    // Snackbar göster
    if (showSnackbar) {
      Get.snackbar(
        'Beklenmeyen Hata',
        appException.message,
        snackPosition: snackPosition,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        isDismissible: true,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  /// Belirli bir API yanıtında kullanıcıya bilgi mesajı gösterir (örn. işlem başarılı)
  void showSuccessMessage(
    String message, {
    String title = 'Başarılı',
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 2),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      duration: duration,
      isDismissible: true,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
}
