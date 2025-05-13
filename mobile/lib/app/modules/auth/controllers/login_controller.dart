import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/modules/auth/controllers/auth_base_controller.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/snackbar_helper.dart';

/// Login ekranının state'ini ve iş mantığını yöneten GetX controller.
class LoginController extends AuthBaseController {
  // Form ve UI kontrolleri
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // UI state
  final RxBool isPasswordVisible = false.obs;

  // Dependency Injection kullanarak constructor injection
  LoginController({required IAuthRepository authRepository}) : super(repository: authRepository);

  @override
  void onClose() {
    // TextEditingController'ların dispose edilmesi
    clearFormInputs([emailController, passwordController]);
    super.onClose();
  }

  /// Şifre alanının görünürlüğünü değiştirir
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Login işlemini gerçekleştirir
  Future<void> login() async {
    // Form doğrulama ve hazırlık
    if (!prepareForProcessing(loginFormKey)) {
      return;
    }

    try {
      final result = await repository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      result.when(
        success: _handleLoginSuccess,
        failure: _handleLoginFailure,
      );
    } on UnexpectedException catch (e) {
      _handleUnexpectedError(e);
    } finally {
      completeProcessing();
    }
  }

  /// Başarılı login işlemini yönetir
  void _handleLoginSuccess(final authResponse) {
    // Başarılı login işleminden sonra ana sayfaya yönlendir
    SnackbarHelper.showSuccess(
      title: 'Giriş Başarılı',
      message: 'Hoş geldiniz ${authResponse.user?.name ?? ''}',
    );
    Get.offAllNamed(AppRoutes.HOME);
  }

  /// Başarısız login işlemini yönetir
  void _handleLoginFailure(final error) {
    errorMessage.value = error.message;

    // ValidationException için form alanlarında hataları göster
    if (error is ValidationException && error.fieldErrors != null) {
      _handleValidationErrors(error);
    } else {
      // Validasyon hatası değilse, standart hata yönetimi kullan
      errorHandler.handleError(
        error,
        message: error.message,
        customTitle: 'Giriş Yapılamadı',
      );
    }
  }

  /// Validasyon hatalarını işler
  void _handleValidationErrors(ValidationException error) {
    final errorMessages = <String>[];

    if (error.fieldErrors!.containsKey('email')) {
      errorMessages.add('E-posta: ${error.fieldErrors!['email']}');
    }

    if (error.fieldErrors!.containsKey('password')) {
      errorMessages.add('Şifre: ${error.fieldErrors!['password']}');
    }

    // Diğer genel hatalar varsa ekle
    if (errorMessages.isEmpty) {
      // Spesifik alan hatası yoksa genel hata mesajını kullan
      errorMessage.value = error.message;
    } else {
      // Alan hatalarını göster
      errorMessage.value = errorMessages.join('\n');
    }

    // Hata yöneticisini kullanarak kullanıcıya bildir
    errorHandler.handleError(error, message: errorMessage.value, customTitle: 'Giriş Yapılamadı');
  }

  /// Beklenmeyen hataları yönetir
  void _handleUnexpectedError(AppException e) {
    errorMessage.value = 'Beklenmedik bir hata oluştu.';
    handleGeneralError(e, customTitle: 'Giriş Yapılamadı');
  }
}
