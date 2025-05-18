import 'package:dio/dio.dart';

import 'app_exception.dart';

/// Ağ istekleri ile ilgili hatalar için exception
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    String? code,
    this.statusCode,
    super.details,
  }) : super(code: code ?? 'NETWORK_ERROR');

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
        message = _extractErrorMessage(responseData) ?? _getDefaultHttpErrorMessage(statusCode);
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
    else if (error.error != null && error.error.toString().contains('SocketException')) {
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
    if (responseData.containsKey('message') && responseData['message'] != null) {
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
            errorMessages.add('$key: ${value.first}');
          } else if (value is String) {
            errorMessages.add('$key: $value');
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
