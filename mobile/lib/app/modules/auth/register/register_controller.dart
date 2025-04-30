import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Register ekranının state'ini ve iş mantığını yöneten GetX controller.
class RegisterController extends GetxController {
  final IAuthRepository _authRepository;

  // Dependency Injection kullanarak constructor injection yap
  RegisterController({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  // Form anahtarı
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // Text Editing Controller'lar
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // State Değişkenleri
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
    if (!registerFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _authRepository.register(
        emailController.text.trim(),
        passwordController.text,
        confirmPasswordController.text, // Şifre tekrarını da gönder
      );

      // Manuel Result'ın when metodunu kullan
      result.when(
        success: (authResponse) {
          // Başarılı kayıt (ve otomatik giriş)
          print('Registration successful: ${authResponse.email}');
          // Ana ekrana yönlendir (tüm geçmişi temizleyerek)
          Get.offAllNamed(AppRoutes.HOME);
        },
        failure: (error) {
          // Başarısız kayıt
          print('Registration failed: ${error.message}');
          errorMessage.value = error.message;
          Get.snackbar(
            'Kayıt Başarısız',
            error.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      // Beklenmedik genel hatalar
      print('Registration unexpected error in Controller: $e');
      errorMessage.value =
          (e is ApiException) ? e.message : 'Beklenmedik bir hata oluştu.';
      Get.snackbar(
        'Hata',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
