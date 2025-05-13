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

    // HTTP yanıt varsa (sunucu yanıtı), onu işle
    if (error.response != null) {
      statusCode = error.response?.statusCode;
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        message = _extractErrorMessage(responseData) ??
            _getDefaultHttpErrorMessage(statusCode);
        errorCode = responseData['code']?.toString() ?? 'SERVER_ERROR';
      } else if (responseData is String && responseData.isNotEmpty) {
        message = responseData;
        errorCode = 'SERVER_ERROR';
      } else {
        message = _getDefaultHttpErrorMessage(statusCode);
        errorCode = 'HTTP_${statusCode ?? "UNKNOWN"}';
      }

      errorDetails = responseData;
    }
    // Bağlantı hatası (SocketException vb.)
    else if (error.error != null &&
        error.error.toString().contains('SocketException')) {
      message = 'İnternet bağlantınızı kontrol edin';
      errorCode = 'CONNECTION_ERROR';
    }
    // Zaman aşımı hatası
    else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      message = 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin';
      errorCode = 'TIMEOUT_ERROR';
    }
    // Diğer hatalar
    else {
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

  /// Backend yanıtından hata mesajını ayıklar
  static String? _extractErrorMessage(Map<String, dynamic> responseData) {
    // 1. Doğrudan 'message' alanı
    if (responseData.containsKey('message') &&
        responseData['message'] != null) {
      return responseData['message'].toString();
    }

    // 2. 'error' alanı
    if (responseData.containsKey('error') && responseData['error'] != null) {
      return responseData['error'].toString();
    }

    // 3. 'errors' listesi
    if (responseData.containsKey('errors')) {
      final errors = responseData['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.map((e) => e.toString()).join(', ');
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
        if (errorMessages.isNotEmpty) {
          return errorMessages.join(', ');
        }
      }
    }

    // 4. 'title' alanı
    if (responseData.containsKey('title')) {
      return responseData['title'].toString();
    }

    return null;
  }

  /// HTTP durum koduna göre varsayılan hata mesajını döndürür
  static String _getDefaultHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek';
      case 401:
        return 'Oturum süresi doldu veya giriş yapılmadı';
      case 403:
        return 'Bu işlem için yetkiniz bulunmuyor';
      case 404:
        return 'İstenen kaynak bulunamadı';
      case 422:
        return 'Gönderilen veriler işlenemedi';
      case 429:
        return 'Çok fazla istek gönderildi, lütfen daha sonra tekrar deneyin';
      case 500:
      case 501:
      case 502:
      case 503:
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin';
      default:
        return 'Sunucu hatası: ${statusCode ?? 'Bilinmeyen durum kodu'}';
    }
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
