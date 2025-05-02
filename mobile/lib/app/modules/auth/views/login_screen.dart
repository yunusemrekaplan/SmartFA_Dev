import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/auth/controllers/login_controller.dart';
import 'package:mobile/app/modules/auth/utils/validators.dart';
import 'package:mobile/app/modules/auth/widgets/auth_button.dart';
import 'package:mobile/app/modules/auth/widgets/auth_footer.dart';
import 'package:mobile/app/modules/auth/widgets/auth_form_field.dart';
import 'package:mobile/app/modules/auth/widgets/auth_header.dart';
import 'package:mobile/app/modules/auth/widgets/error_message.dart';
import 'package:mobile/app/modules/auth/widgets/password_field.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Kullanıcı giriş ekranı.
class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo ve Hoşgeldin Metni
                  const AuthHeader(
                    title: 'SmartFA',
                    subtitle: 'Finansal Asistanınıza Hoş Geldiniz',
                    logoSize: 90,
                  ),

                  const SizedBox(height: 48),

                  // Form Başlığı
                  Text(
                    'Giriş Yap',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),

                  // E-posta Alanı
                  AuthFormField(
                    controller: controller.emailController,
                    labelText: 'E-posta',
                    hintText: 'ornek@mail.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: AuthValidators.validateEmail,
                  ),
                  const SizedBox(height: 16.0),

                  // Şifre Alanı
                  PasswordField(
                    controller: controller.passwordController,
                    labelText: 'Şifre',
                    hintText: '••••••••',
                    isPasswordVisible: controller.isPasswordVisible,
                    toggleVisibility: controller.togglePasswordVisibility,
                    textInputAction: TextInputAction.done,
                    validator: AuthValidators.validatePassword,
                    onFieldSubmitted: (_) => controller.login(),
                  ),

                  // Şifremi Unuttum Linki
                  _buildForgotPasswordLink(context),

                  // Hata Mesajı Alanı
                  Obx(() => ErrorMessageBox(message: controller.errorMessage.value)),

                  const SizedBox(height: 32.0),

                  // Giriş Yap Butonu
                  Obx(() => AuthButton(
                        onPressed: controller.login,
                        isLoading: controller.isLoading.value,
                        label: 'Giriş Yap',
                        icon: Icons.login,
                      )),

                  const SizedBox(height: 24.0),

                  // Kayıt Ol Bölümü
                  AuthFooter(
                    question: 'Hesabın yok mu?',
                    actionText: 'Kayıt Ol',
                    onActionPressed: () => Get.toNamed(AppRoutes.REGISTER),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Şifremi unuttum linki
  Widget _buildForgotPasswordLink(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(top: 12),
      child: TextButton(
        onPressed: () => _showFeatureNotImplementedSnackbar(context),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(50, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Şifremi Unuttum'),
      ),
    );
  }

  /// Uygulanmamış özellikler için snackbar gösterimi
  void _showFeatureNotImplementedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu özellik henüz uygulanmadı'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
