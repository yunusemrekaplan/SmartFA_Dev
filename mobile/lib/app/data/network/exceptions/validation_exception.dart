import 'app_exception.dart';

/// Kullanıcı girişi doğrulama hataları için exception
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
    String? code,
    super.details,
  }) : super(
          code: code ?? 'VALIDATION_ERROR',
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
      if (responseData.containsKey('message') && responseData['message'] != null) {
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
