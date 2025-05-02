import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/modules/auth/controllers/auth_base_controller.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:mobile/app/utils/exceptions.dart';

/// Register ekranının state'ini ve iş mantığını yöneten GetX controller.
class RegisterController extends AuthBaseController {
  // Form ve input kontrolleri
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // UI state
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  RegisterController({required IAuthRepository authRepository})
      : super(repository: authRepository);

  @override
  void onClose() {
    clearFormInputs(
        [emailController, passwordController, confirmPasswordController]);
    super.onClose();
  }

  /// Şifre alanının görünürlüğünü değiştirir.
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Şifre tekrarı alanının görünürlüğünü değiştirir.
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Register işlemini gerçekleştirir.
  Future<void> register() async {
    if (!prepareForProcessing(registerFormKey)) {
      return;
    }

    try {
      final result = await repository.register(
        emailController.text.trim(),
        passwordController.text,
        confirmPasswordController.text,
      );

      result.when(
        success: _handleRegisterSuccess,
        failure: _handleRegisterFailure,
      );
    } catch (e) {
      _handleUnexpectedError(e);
    } finally {
      completeProcessing();
    }
  }

  /// Başarılı kayıt işlemini yönetir
  void _handleRegisterSuccess(final authResponse) {
    errorHandler.showSuccessMessage('Kayıt işlemi başarılı');
    Get.offAllNamed(AppRoutes.HOME); // Ana sayfaya yönlendir
  }

  /// Başarısız kayıt işlemini yönetir
  void _handleRegisterFailure(final error) {
    errorMessage.value = error.message;

    // ValidationException için form alanlarında hataları göster
    if (error is ValidationException && error.fieldErrors != null) {
      _handleValidationErrors(error);
    } else {
      // Validasyon hatası değilse, standart hata yönetimi kullan
      errorHandler.handleError(error, customTitle: 'Kayıt Başarısız');
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

    if (error.fieldErrors!.containsKey('confirmPassword')) {
      errorMessages
          .add('Şifre Tekrarı: ${error.fieldErrors!['confirmPassword']}');
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
    errorHandler.handleError(error, customTitle: 'Kayıt Başarısız');
  }

  /// Beklenmeyen hataları yönetir
  void _handleUnexpectedError(dynamic e) {
    errorMessage.value =
        'Kayıt işlemi sırasında beklenmedik bir hata oluştu. Lütfen tekrar deneyin.';
    handleGeneralError(e, customTitle: 'Kayıt Başarısız');
  }
}
