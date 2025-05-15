import 'package:get/get.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';

/// Auth verilerini yöneten servis
/// SRP (Single Responsibility Principle) - Auth API istekleri tek bir sınıfta toplanır
class AuthDataService {
  final IAuthRepository _authRepository;
  final ErrorHandler _errorHandler = ErrorHandler();

  // Observable state
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  AuthDataService(this._authRepository);

  /// Kullanıcı giriş işlemini gerçekleştirir
  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _authRepository.login(email, password);

      return result.when(
        success: (response) {
          return true;
        },
        failure: (error) {
          _handleAuthError(error, 'Giriş Yapılamadı');
          return false;
        },
      );
    } on UnexpectedException catch (e) {
      _handleUnexpectedError(e, 'Giriş Yapılamadı');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Kullanıcı kayıt işlemini gerçekleştirir
  Future<bool> register(
      String email, String password, String confirmPassword) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result =
          await _authRepository.register(email, password, confirmPassword);

      return result.when(
        success: (response) {
          return true;
        },
        failure: (error) {
          _handleAuthError(error, 'Kayıt Başarısız');
          return false;
        },
      );
    } on UnexpectedException catch (e) {
      _handleUnexpectedError(e, 'Kayıt Başarısız');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Şifre sıfırlama işlemini başlatır
  Future<bool> forgotPassword(String email) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Bu metodun implementasyonu backend'e bağlı olarak değişebilir
      // Şu an için sadece örnek olarak boş bir metod
      return true;
    } catch (e) {
      errorMessage.value = 'Şifre sıfırlama isteği gönderilemedi.';
      _errorHandler.handleError(
        e as AppException,
        message: errorMessage.value,
        customTitle: 'Şifre Sıfırlama Hatası',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Kullanıcı çıkış işlemini gerçekleştirir
  Future<bool> logout() async {
    isLoading.value = true;

    try {
      // Logout işlemi backend'e bağlı olarak uygulanabilir
      // Şu an için sadece yerel state'i temizleme işlemi
      return true;
    } catch (e) {
      _errorHandler.handleError(
        e as AppException,
        message: 'Çıkış yapılırken bir hata oluştu.',
        customTitle: 'Çıkış Hatası',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// AuthException handling
  void _handleAuthError(AppException error, String title) {
    errorMessage.value = error.message;

    // ValidationException check and field error extraction
    if (error is ValidationException && error.fieldErrors != null) {
      final fieldErrors = <String>[];
      error.fieldErrors!.forEach((field, message) {
        fieldErrors.add('$field: $message');
      });

      if (fieldErrors.isNotEmpty) {
        errorMessage.value = fieldErrors.join('\n');
      }
    }

    _errorHandler.handleError(
      error,
      message: errorMessage.value,
      customTitle: title,
    );
  }

  /// Unexpected errors handling
  void _handleUnexpectedError(UnexpectedException e, String title) {
    errorMessage.value = 'Beklenmedik bir hata oluştu, lütfen tekrar deneyin.';
    _errorHandler.handleError(
      e,
      message: errorMessage.value,
      customTitle: title,
    );
  }
}
