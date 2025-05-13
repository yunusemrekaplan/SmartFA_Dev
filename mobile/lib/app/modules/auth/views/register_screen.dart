import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/auth/controllers/register_controller.dart';
import 'package:mobile/app/modules/auth/utils/validators.dart';
import 'package:mobile/app/modules/auth/widgets/auth_button.dart';
import 'package:mobile/app/modules/auth/widgets/auth_footer.dart';
import 'package:mobile/app/modules/auth/widgets/auth_header.dart';
import 'package:mobile/app/modules/auth/widgets/auth_terms.dart';
import 'package:mobile/app/modules/auth/widgets/error_message.dart';
import 'package:mobile/app/modules/auth/widgets/password_field.dart';
import 'package:mobile/app/modules/auth/widgets/auth_form_field.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Kullanıcı kayıt ekranı.
class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: controller.registerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Geri butonu
                  _buildBackButton(),

                  const SizedBox(height: 24),

                  // Logo ve Başlık
                  const AuthHeader(
                    title: 'Yeni Hesap Oluştur',
                    subtitle:
                        'Finansal yolculuğunuza başlamak için hesabınızı oluşturun',
                    logoSize: 80,
                  ),

                  const SizedBox(height: 40),

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
                    textInputAction: TextInputAction.next,
                    validator: AuthValidators.validatePassword,
                  ),
                  const SizedBox(height: 16.0),

                  // Şifre Tekrarı Alanı
                  PasswordField(
                    controller: controller.confirmPasswordController,
                    labelText: 'Şifre Tekrarı',
                    hintText: '••••••••',
                    isPasswordVisible: controller.isConfirmPasswordVisible,
                    toggleVisibility:
                        controller.toggleConfirmPasswordVisibility,
                    textInputAction: TextInputAction.done,
                    validator: (value) =>
                        AuthValidators.validateConfirmPassword(
                      value,
                      controller.passwordController.text,
                    ),
                    onFieldSubmitted: (_) => controller.register(),
                  ),

                  // Kullanım Koşulları
                  const AuthTermsText(),

                  // Hata Mesajı Alanı
                  Obx(() => ErrorMessageBox(
                        message: controller.errorMessage.value,
                      )),

                  const SizedBox(height: 32.0),

                  // Kayıt Ol Butonu
                  Obx(() => AuthButton(
                        onPressed: controller.register,
                        isLoading: controller.isLoading.value,
                        label: 'Kayıt Ol',
                        icon: Icons.app_registration,
                      )),

                  const SizedBox(height: 24.0),

                  // Giriş Yap Yönlendirme
                  AuthFooter(
                    question: 'Zaten hesabın var mı?',
                    actionText: 'Giriş Yap',
                    onActionPressed: controller.goToLogin,
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

  /// Geri butonu
  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: IconButton(
        onPressed: controller.goToLogin,
        icon: const Icon(Icons.arrow_back_ios),
        color: AppColors.textPrimary,
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
