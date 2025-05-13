import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Auth formlarını yöneten servis
/// SRP (Single Responsibility Principle) - Form işlemleri ve validasyon tek bir sınıfta toplanır
class AuthFormService {
  // Login form kontrolleri
  final loginFormKey = GlobalKey<FormState>();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final RxBool isLoginPasswordVisible = false.obs;

  // Register form kontrolleri
  final registerFormKey = GlobalKey<FormState>();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isRegisterPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  /// Form alanlarını temizler
  void clearInputFields() {
    // Login form alanlarını temizle
    loginEmailController.clear();
    loginPasswordController.clear();

    // Register form alanlarını temizle
    registerEmailController.clear();
    registerPasswordController.clear();
    confirmPasswordController.clear();
  }

  /// Controller'ların kaynakları serbest bırakılır
  /// Bu metot sadece servis tamamen bellekten atılırken çağrılmalıdır
  /// NOT: GetX fenix parametresi true olduğunda, servisler bellekte kalıcı olur
  /// ve controller'ları dispose etmemize genellikle gerek kalmaz
  void disposeControllers() {
    try {
      // Login form controller'ları
      if (loginEmailController.hasListeners) {
        loginEmailController.dispose();
      }
      if (loginPasswordController.hasListeners) {
        loginPasswordController.dispose();
      }

      // Register form controller'ları
      if (registerEmailController.hasListeners) {
        registerEmailController.dispose();
      }
      if (registerPasswordController.hasListeners) {
        registerPasswordController.dispose();
      }
      if (confirmPasswordController.hasListeners) {
        confirmPasswordController.dispose();
      }
    } catch (e) {
      // Controller zaten dispose edilmiş olabilir
      print('Controller dispose hatası: $e');
    }
  }

  /// Login şifre görünürlüğünü değiştirir
  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  /// Register şifre görünürlüğünü değiştirir
  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible.value = !isRegisterPasswordVisible.value;
  }

  /// Şifre tekrarı görünürlüğünü değiştirir
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Login formunun geçerliliğini kontrol eder
  bool validateLoginForm() {
    return loginFormKey.currentState?.validate() ?? false;
  }

  /// Register formunun geçerliliğini kontrol eder
  bool validateRegisterForm() {
    return registerFormKey.currentState?.validate() ?? false;
  }
}
