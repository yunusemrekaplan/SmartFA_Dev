import 'package:dio/dio.dart';

/// Uygulama genelinde kullanılacak exception sınıfları.
/// Bu sınıflar Result<T, E> yapısı ile birlikte kullanılır.

/// Tüm uygulama exception'larının temel sınıfı
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

/// Ağ istekleri ile ilgili hatalar için exception
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required String message,
    String? code,
    this.statusCode,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'NETWORK_ERROR',
          details: details,
        );

  /// Dio hatasından NetworkException oluşturmak için factory
  factory NetworkException.fromDioError(DioException error) {
    String message;
    String? errorCode;
    int? statusCode;
    dynamic errorDetails;

    if (error.response != null) {
      // Sunucudan gelen hata yanıtı
      statusCode = error.response?.statusCode;

      // Sunucudan dönen veriyi ayrıştır
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        // Önce 'message' veya 'error' alanını kontrol et
        if (responseData.containsKey('message') &&
            responseData['message'] != null) {
          message = responseData['message'].toString();
        } else if (responseData.containsKey('error') &&
            responseData['error'] != null) {
          message = responseData['error'].toString();
        } else if (responseData.containsKey('errors')) {
          // API yanıt formatı errors[] listesi içeriyor olabilir
          final errors = responseData['errors'];
          if (errors is List && errors.isNotEmpty) {
            message = errors.map((e) => e.toString()).join(', ');
          } else if (errors is Map<String, dynamic>) {
            // Form alanlarına göre hata mesajı dönüyor olabilir
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorMessages.add('${key}: ${value.first}');
              } else if (value is String) {
                errorMessages.add('${key}: $value');
              }
            });
            message = errorMessages.join(', ');
          } else {
            message = 'Sunucu hatası';
          }
        } else if (responseData.containsKey('title')) {
          // Bazı API'ler title alanı kullanabilir
          message = responseData['title'].toString();
        } else {
          message = 'Sunucu hatası: ${statusCode ?? 'Bilinmeyen durum kodu'}';
        }

        // Hata kodunu al (varsa)
        errorCode = responseData['code']?.toString() ?? 'SERVER_ERROR';
      } else if (responseData is String && responseData.isNotEmpty) {
        // Doğrudan string mesaj geldiyse kullanalım
        message = responseData;
        errorCode = 'SERVER_ERROR';
      } else {
        // Ayrıştırılabilir bir yanıt yoksa HTTP durum koduna göre mesaj oluştur
        switch (statusCode) {
          case 400:
            message = 'Geçersiz istek';
            break;
          case 401:
            message = 'Oturum süresi doldu veya giriş yapılmadı';
            break;
          case 403:
            message = 'Bu işlem için yetkiniz bulunmuyor';
            break;
          case 404:
            message = 'İstenen kaynak bulunamadı';
            break;
          case 422:
            message = 'Gönderilen veriler işlenemedi';
            break;
          case 500:
          case 501:
          case 502:
          case 503:
            message = 'Sunucu hatası. Lütfen daha sonra tekrar deneyin';
            break;
          default:
            message = 'Sunucu hatası: ${statusCode ?? 'Bilinmeyen durum kodu'}';
            break;
        }
        errorCode = 'HTTP_${statusCode ?? "UNKNOWN"}';
      }

      errorDetails = responseData;
    } else if (error.error != null &&
        error.error.toString().contains('SocketException')) {
      // Bağlantı hatası
      message = 'İnternet bağlantınızı kontrol edin';
      errorCode = 'CONNECTION_ERROR';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      // Zaman aşımı hatası
      message = 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin';
      errorCode = 'TIMEOUT_ERROR';
    } else {
      // Diğer hatalar
      message = 'Beklenmeyen bir hata oluştu: ${error.message}';
      errorCode = 'UNKNOWN_ERROR';
    }

    return NetworkException(
      message: message,
      code: errorCode,
      statusCode: statusCode,
      details: errorDetails,
    );
  }
}

/// Kullanıcı girişi doğrulama hataları için exception
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required String message,
    this.fieldErrors,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          details: details,
        );

  /// Belirli bir alan için hata mesajını döndürür
  String? getFieldError(String fieldName) => fieldErrors?[fieldName];

  /// Dio yanıtından ValidationException oluşturmak için factory
  factory ValidationException.fromDioResponse(dynamic responseData,
      {String defaultMessage = 'Form bilgileri geçersiz'}) {
    String message = defaultMessage;
    Map<String, String>? fieldErrors;

    if (responseData is Map<String, dynamic>) {
      // Önce doğrudan mesaj alanı kontrol edilir
      if (responseData.containsKey('message') &&
          responseData['message'] != null) {
        message = responseData['message'].toString();
      }

      // Sunucudan gelen alan hatalarını ayrıştır
      if (responseData.containsKey('errors')) {
        final errors = responseData['errors'];
        fieldErrors = {};

        if (errors is Map<String, dynamic>) {
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              fieldErrors![key] = value.first.toString();
            } else if (value is String) {
              fieldErrors![key] = value;
            }
          });
        } else if (errors is List && errors.isNotEmpty) {
          // API'ler alan adı olmadan doğrudan hata mesajları listesi gönderebilir
          message = errors.map((e) => e.toString()).join(', ');
        }
      }
    }

    return ValidationException(
      message: message,
      fieldErrors: fieldErrors,
      details: responseData,
    );
  }
}

/// Kimlik doğrulama ve yetkilendirme hataları için exception
class AuthException extends AppException {
  final bool isTokenExpired;

  const AuthException({
    required String message,
    this.isTokenExpired = false,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? (isTokenExpired ? 'TOKEN_EXPIRED' : 'AUTH_ERROR'),
          details: details,
        );
}

/// Veri bulunamadı hatası için exception
class NotFoundException extends AppException {
  final String? resourceType;
  final String? resourceId;

  const NotFoundException({
    required String message,
    this.resourceType,
    this.resourceId,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'NOT_FOUND',
          details: details,
        );
}

/// Yerel depolama hataları için exception
class StorageException extends AppException {
  final String? operation;

  const StorageException({
    required String message,
    this.operation,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'STORAGE_ERROR',
          details: details,
        );
}

/// Beklenmeyen hatalar için exception
class UnexpectedException extends AppException {
  const UnexpectedException({
    String message = 'Beklenmeyen bir hata oluştu',
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'UNEXPECTED_ERROR',
          details: details,
        );

  /// Genel bir exception'dan UnexpectedException oluşturmak için factory
  factory UnexpectedException.fromException(Exception exception) {
    return UnexpectedException(
      message: 'Beklenmeyen hata: ${exception.toString()}',
      details: exception,
    );
  }
}
