import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/auth/services/auth_data_service.dart';
import 'package:mobile/app/modules/auth/services/auth_form_service.dart';
import 'package:mobile/app/modules/auth/services/auth_navigation_service.dart';
import 'package:mobile/app/modules/auth/services/auth_ui_service.dart';

/// Login ekranının state'ini ve iş mantığını yöneten GetX controller.
/// DIP (Dependency Inversion Principle) - Yüksek seviyeli modüller düşük seviyeli modüllere bağlı değil
/// ISP (Interface Segregation Principle) - Kullanılmayan arayüzlere bağımlı olunmamalı
class LoginController extends GetxController {
  // Servisler - Bağımlılık Enjeksiyonu
  final AuthDataService _dataService;
  final AuthFormService _formService;
  final AuthNavigationService _navigationService;
  final AuthUIService _uiService;

  LoginController({
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
  GlobalKey<FormState> get loginFormKey => _formService.loginFormKey;
  TextEditingController get emailController =>
      _formService.loginEmailController;
  TextEditingController get passwordController =>
      _formService.loginPasswordController;
  RxBool get isPasswordVisible => _formService.isLoginPasswordVisible;

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
    _formService.toggleLoginPasswordVisibility();
  }

  /// Login işlemini gerçekleştirir
  Future<void> login() async {
    // Form doğrulama
    if (!_formService.validateLoginForm()) {
      return;
    }

    // Login işlemini gerçekleştir
    final success = await _dataService.login(
      emailController.text.trim(),
      passwordController.text,
    );

    if (success) {
      _uiService.showLoginSuccessMessage(null);
      _navigationService.goToHomeAfterAuth();
    }
  }

  /// Register ekranına yönlendirir
  void goToRegister() {
    _navigationService.goToRegister();
  }

  /// Şifremi unuttum özelliğini gösterir
  void showForgotPassword(BuildContext context) {
    _uiService.showFeatureNotImplementedMessage(context);
  }
}
