import 'app_exception.dart';

/// Kimlik doğrulama ve yetkilendirme hataları için exception
class AuthException extends AppException {
  final bool isTokenExpired;

  const AuthException({
    required super.message,
    this.isTokenExpired = false,
    String? code,
    super.details,
  }) : super(code: code ?? (isTokenExpired ? 'TOKEN_EXPIRED' : 'AUTH_ERROR'));
}
