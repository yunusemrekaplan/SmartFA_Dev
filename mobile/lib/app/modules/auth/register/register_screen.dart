import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controller ve Rota importları
import 'register_controller.dart';
// Tema importları (varsa)
// import '../../../theme/colors.dart';
// Ortak widget importları (varsa)
// import '../../../widgets/custom_button.dart';
// import '../../../widgets/loading_indicator.dart';

/// Kullanıcı kayıt ekranı.
class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        centerTitle: true,
        // Geri butonu otomatik olarak eklenir (Get.toNamed kullandığımızda)
        // veya manuel eklenebilir: leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.registerFormKey, // Controller'daki form anahtarı
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // E-posta Alanı
                TextFormField(
                  controller: controller.emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta boş olamaz.';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Geçerli bir e-posta giriniz.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Şifre Alanı
                Obx(() => TextFormField(
                  controller: controller.passwordController,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                  obscureText: !controller.isPasswordVisible.value,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre boş olamaz.';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır.';
                    }
                    // İsteğe bağlı: Şifre tekrarı ile eşleşme kontrolü burada da yapılabilir
                    // if (controller.confirmPasswordController.text.isNotEmpty && value != controller.confirmPasswordController.text) {
                    //   return 'Şifreler eşleşmiyor.';
                    // }
                    return null;
                  },
                )),
                const SizedBox(height: 16.0),

                // Şifre Tekrarı Alanı
                Obx(() => TextFormField(
                  controller: controller.confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrarı',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  ),
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre tekrarı boş olamaz.';
                    }
                    // Girilen şifre ile eşleşip eşleşmediğini kontrol et
                    if (value != controller.passwordController.text) {
                      return 'Şifreler eşleşmiyor.';
                    }
                    return null;
                  },
                  // Formu göndermek için
                  onFieldSubmitted: (_) => controller.register(),
                )),
                const SizedBox(height: 8.0),

                // Hata Mesajı Alanı
                Obx(() {
                  if (controller.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),

                const SizedBox(height: 24.0),

                // Kayıt Ol Butonu
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.register,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('Kayıt Ol'),
                )),
                const SizedBox(height: 16.0),

                // Giriş Yap Butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Zaten hesabın var mı?"),
                    TextButton(
                      onPressed: () {
                        // Geri git (Login ekranına)
                        Get.back();
                      },
                      child: const Text('Giriş Yap'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
