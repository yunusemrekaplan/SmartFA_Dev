import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/bindings/initial_binding.dart';
import 'package:mobile/app/navigation/app_pages.dart';
import 'package:mobile/app/theme/app_theme.dart';

void main() {
  // Uygulama başlamadan önce yapılması gerekenler (varsa)
  WidgetsFlutterBinding.ensureInitialized();
  // Örn: Dependency Injection Binding'leri
  // InitialBinding().dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Akıllı Finans Yönetimi',
      debugShowCheckedModeBanner: false,
      // Debug banner'ını kaldır

      // Temaları ata
      theme: AppTheme.lightTheme,
      //darkTheme: AppTheme.darkTheme, // Koyu tema (isteğe bağlı)
      themeMode: ThemeMode.system,

      initialRoute: AppPages.INITIAL_ROUTE,
      getPages: AppPages.routes, // Rota listesi

      // Başlangıç Binding'i (Genel bağımlılıklar için - Opsiyonel)
      initialBinding: InitialBinding(),
    );
  }
}
