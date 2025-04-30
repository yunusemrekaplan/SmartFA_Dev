

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Login ekranının state'ini ve iş mantığını yöneten GetX controller.
class LoginController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

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
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // --- DEĞİŞİKLİK: Manuel when Metodu Kullanımı ---
      result.when(
          success: (authResponse) {
            // Başarılı giriş
            print('Login successful: ${authResponse.email}');
            Get.offAllNamed(AppRoutes.HOME); // Ana ekrana yönlendir
          },
          failure: (error) {
            // Başarısız giriş
            print('Login failed: ${error.message}');
            errorMessage.value = error.message; // Hata mesajını state'e ata
            Get.snackbar(
              'Giriş Başarısız',
              error.message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
          }
      );

    } catch (e) {
      // Repository katmanından beklenmedik bir hata fırlatılırsa
      print('Login unexpected error in Controller: $e');
      errorMessage.value = (e is ApiException) ? e.message : 'Beklenmedik bir hata oluştu.';
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
