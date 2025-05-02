/*
import 'package:dio/dio.dart'; // DioException için

/// API veya diğer veri katmanı hatalarını temsil eden temel istisna sınıfı.
class ApiException implements Exception {
  final String message;
  final int? statusCode; // HTTP durum kodu (varsa)
  final dynamic errorData; // Sunucudan gelen ek hata verisi (varsa)

  ApiException({required this.message, this.statusCode, this.errorData});

  /// DioException'dan ApiException oluşturur.
  factory ApiException.fromDioError(DioException dioError) {
    String errorMessage =
        "Bir ağ hatası oluştu. Lütfen internet bağlantınızı kontrol edin veya daha sonra tekrar deneyin.";
    int? statusCode = dioError.response?.statusCode;
    dynamic errorData = dioError.response?.data;

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = "Sunucuya bağlanırken zaman aşımı oluştu.";
        break;
      case DioExceptionType.badResponse:
        // Sunucudan gelen hata mesajını almaya çalış
        if (errorData is Map<String, dynamic>) {
          // Backend'in ErrorResponseDto formatına göre ayarla (varsayım)
          final errors = errorData['errors'] as List<dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            // Hataları birleştirerek daha okunabilir hale getir
            errorMessage = errors.map((e) => e.toString()).join('\n');
          } else {
            errorMessage = errorData['title']?.toString() ?? 'Sunucu hatası: $statusCode';
          }
        } else if (errorData is String && errorData.isNotEmpty) {
          errorMessage = errorData; // Direkt string hata mesajı gelmiş olabilir
        } else {
          errorMessage = 'Geçersiz yanıt (${statusCode ?? 'Durum Kodu Yok'}).';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = "İstek iptal edildi.";
        break;
      case DioExceptionType.connectionError:
        errorMessage = "İnternet bağlantısı hatası.";
        break;
      case DioExceptionType.unknown:
      default:
        errorMessage = "Bilinmeyen bir hata oluştu: ${dioError.message}";
        break;
    }
    return ApiException(message: errorMessage, statusCode: statusCode, errorData: errorData);
  }

  /// Diğer Exception türlerinden ApiException oluşturur.
  factory ApiException.fromException(Exception e) {
    return ApiException(message: 'Beklenmedik bir hata oluştu: ${e.toString()}');
  }

  @override
  String toString() => 'ApiException(message: $message, statusCode: $statusCode)';
}

// İhtiyaca göre daha spesifik Exception sınıfları türetilebilir:
// class NetworkException extends ApiException { NetworkException(String message) : super(message: message); }
// class AuthenticationException extends ApiException { AuthenticationException(String message) : super(message: message); }
// class NotFoundException extends ApiException { NotFoundException(String resource) : super(message: '$resource bulunamadı.'); }
*/
