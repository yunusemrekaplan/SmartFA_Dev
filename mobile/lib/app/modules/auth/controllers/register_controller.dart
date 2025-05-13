import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/auth/services/auth_data_service.dart';
import 'package:mobile/app/modules/auth/services/auth_form_service.dart';
import 'package:mobile/app/modules/auth/services/auth_navigation_service.dart';
import 'package:mobile/app/modules/auth/services/auth_ui_service.dart';

/// Register ekranının state'ini ve iş mantığını yöneten GetX controller.
/// DIP (Dependency Inversion Principle) - Yüksek seviyeli modüller düşük seviyeli modüllere bağlı değil
/// ISP (Interface Segregation Principle) - Kullanılmayan arayüzlere bağımlı olunmamalı
class RegisterController extends GetxController {
  // Servisler - Bağımlılık Enjeksiyonu
  final AuthDataService _dataService;
  final AuthFormService _formService;
  final AuthNavigationService _navigationService;
  final AuthUIService _uiService;

  RegisterController({
    required AuthDataService dataService,
    required AuthFormService formService,
    required AuthNavigationService navigationService,
    required AuthUIService uiService,
  })  : _dataService = dataService,
        _formService = formService,
        _navigationService = navigationService,
        _uiService = uiService;

  // --- Convenience Getters (Delegasyon Paterni) ---

  // Form Servisi Delegasyonları
  GlobalKey<FormState> get registerFormKey => _formService.registerFormKey;
  TextEditingController get emailController =>
      _formService.registerEmailController;
  TextEditingController get passwordController =>
      _formService.registerPasswordController;
  TextEditingController get confirmPasswordController =>
      _formService.confirmPasswordController;
  RxBool get isPasswordVisible => _formService.isRegisterPasswordVisible;
  RxBool get isConfirmPasswordVisible => _formService.isConfirmPasswordVisible;

  // Veri Servisi Delegasyonları
  RxBool get isLoading => _dataService.isLoading;
  RxString get errorMessage => _dataService.errorMessage;

  // --- Lifecycle Metotları ---

  @override
  void onClose() {
    // TextEditingController'ları dispose etmeye gerek yok
    // _formService fenix: true ile kaydedildiği için ve
    // controller'lar farklı ekranlarda kullanıldığından
    // burada dispose çağrısını kaldırıyoruz
    super.onClose();
  }

  // --- Metotlar ---

  /// Şifre alanının görünürlüğünü değiştirir
  void togglePasswordVisibility() {
    _formService.toggleRegisterPasswordVisibility();
  }

  /// Şifre tekrarı alanının görünürlüğünü değiştirir
  void toggleConfirmPasswordVisibility() {
    _formService.toggleConfirmPasswordVisibility();
  }

  /// Register işlemini gerçekleştirir
  Future<void> register() async {
    // Form doğrulama
    if (!_formService.validateRegisterForm()) {
      return;
    }

    // Register işlemini gerçekleştir
    final success = await _dataService.register(
      emailController.text.trim(),
      passwordController.text,
      confirmPasswordController.text,
    );

    if (success) {
      _uiService.showRegisterSuccessMessage();
      _navigationService.goToHomeAfterAuth();
    }
  }

  /// Login ekranına geri dön
  void goToLogin() {
    _navigationService.goBack();
  }
}
