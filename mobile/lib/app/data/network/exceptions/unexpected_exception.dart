import 'app_exception.dart';

/// Beklenmeyen hatalar için exception
class UnexpectedException extends AppException {
  const UnexpectedException({
    super.message = 'Beklenmeyen bir hata oluştu',
    String? code,
    super.details,
  }) : super(code: code ?? 'UNEXPECTED_ERROR');

  /// Genel bir exception'dan UnexpectedException oluşturmak için factory
  factory UnexpectedException.fromException(Exception exception) {
    return UnexpectedException(
      message: 'Beklenmeyen hata: ${exception.toString()}',
      details: exception,
    );
  }
}
