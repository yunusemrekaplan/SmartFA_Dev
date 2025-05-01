// Ortak widget importları (varsa)
// import '../../../widgets/custom_button.dart';
// import '../../../widgets/loading_indicator.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/auth/login/login_controller.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Kullanıcı giriş ekranı.
/// GetView<LoginController> kullanarak controller'a doğrudan erişim sağlar.
class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GetView kullandığımız için controller'a doğrudan 'controller' ile erişebiliriz.
    // Alternatif olarak: final controller = Get.find<LoginController>();

    return Scaffold(
      // Klavye açıldığında taşmayı önlemek için
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        centerTitle: true,
      ),
      body: SafeArea(
        // Cihaz çentikleri vb. için güvenli alan
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.loginFormKey, // Controller'daki form anahtarını ata
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Ortala
              crossAxisAlignment: CrossAxisAlignment.stretch, // Genişlet
              children: [
                // Uygulama Logosu (Opsiyonel)
                // FlutterLogo(size: 80),
                // SizedBox(height: 40),

                // E-posta Alanı
                TextFormField(
                  controller: controller.emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email_outlined),
                    // hintText: 'ornek@eposta.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  // Sonraki alana geç
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta boş olamaz.';
                    }
                    if (!GetUtils.isEmail(value)) {
                      // GetX'in email validator'ı
                      return 'Geçerli bir e-posta giriniz.';
                    }
                    return null; // Geçerli
                  },
                ),
                const SizedBox(height: 16.0),

                // Şifre Alanı
                // Obx ile şifre görünürlüğü state'ini dinle
                Obx(() => TextFormField(
                      controller: controller.passwordController,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outline),
                        // Şifre görünürlüğünü değiştiren ikon butonu
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
                      // Görünürlüğü state'e bağla
                      textInputAction: TextInputAction.done,
                      // Klavye "Bitti" butonu
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre boş olamaz.';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalıdır.';
                        }
                        return null; // Geçerli
                      },
                      // Formu göndermek için (opsiyonel)
                      onFieldSubmitted: (_) => controller.login(),
                    )),
                const SizedBox(height: 8.0),

                // Hata Mesajı Alanı (Opsiyonel)
                Obx(() {
                  if (controller.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return const SizedBox
                        .shrink(); // Hata yoksa boşluk gösterme
                  }
                }),

                const SizedBox(height: 24.0),

                // Giriş Yap Butonu
                // Obx ile isLoading state'ini dinle
                Obx(() => ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.login,
                      // Yükleniyorsa butonu deaktif et
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              // Yükleme göstergesi
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Giriş Yap'),
                    )),
                const SizedBox(height: 16.0),

                // Kayıt Ol Butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Hesabın yok mu?"),
                    TextButton(
                      onPressed: () {
                        // Kayıt ekranına git
                        Get.toNamed(AppRoutes.REGISTER);
                      },
                      child: const Text('Kayıt Ol'),
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
