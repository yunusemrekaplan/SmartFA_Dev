import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/splash/splash_controller.dart';

/// Uygulama açılışında gösterilen splash ekranı
class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Uygulama logosu veya ikonu
              Icon(
                Icons.account_balance_wallet,
                size: 100,
                color: Colors.white,
              ),

              const SizedBox(height: 32),

              // Uygulama adı
              Text(
                'Akıllı Finans Yönetimi',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white, // Rengi override
                      // fontSize: 28, // displayLarge zaten 28
                      // fontWeight: FontWeight.bold, // displayLarge zaten bold
                    ),
              ),

              const SizedBox(height: 64),

              // Yükleniyor göstergesi
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
