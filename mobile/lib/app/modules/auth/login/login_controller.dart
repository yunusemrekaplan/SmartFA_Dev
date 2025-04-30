import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Login ekranının state'ini ve iş mantığını yöneten GetX controller.
class LoginController extends GetxController {
  final IAuthRepository _authRepository;

  // Dependency Injection kullanarak constructor injection yap
  LoginController({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) {
      print('>>> LoginController: Form validation failed');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    print(
        '>>> LoginController: Attempting login for user: ${emailController.text.trim()}');

    try {
      final result = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      result.when(
        success: (authResponse) {
          print('>>> LoginController: Login successful, access token received');
          print('>>> LoginController: User email: ${authResponse.email}');
          print('>>> LoginController: Redirecting to HOME');

          // Başarılı login işleminden sonra ana sayfaya yönlendir
          Get.offAllNamed(AppRoutes.HOME);

          // Bildirim göster
          Get.snackbar(
            'Başarılı',
            'Giriş yapıldı',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        failure: (error) {
          print('>>> LoginController: Login failed: ${error.message}');

          // Hata mesajını göster
          Get.snackbar(
            'Hata',
            error.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      // Repository katmanından beklenmedik bir hata fırlatılırsa
      print('>>> LoginController: Unexpected error: $e');
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
