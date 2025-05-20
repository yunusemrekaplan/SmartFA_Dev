import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/app/core/di/initial_binding.dart';
import 'package:mobile/app/navigation/app_pages.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Uygulama başlamadan önce yapılması gerekenler
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('tr', null);

  // Hata ayıklama için Flutter hata işleyicisini özelleştir
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Hata loglarını görüntüle
    print('>>> Flutter Error: ${details.exception}');
    print('>>> Stack trace: ${details.stack}');
  };

  // InitialBinding ile bağımlılıkları yükle
  try {
    InitialBinding().dependencies();
    print('>>> InitialBinding başarıyla yüklendi.');
  } catch (e) {
    print('>>> InitialBinding hatası: $e');
  }

  runApp(const MyApp());

  print(
      '>>> Uygulama başlatıldı - başlangıç rotası: ${AppPages.INITIAL_ROUTE}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Akıllı Finans Yönetimi',
      debugShowCheckedModeBanner: false, // Debug banner'ını kaldır

      // Rota değişikliklerini izle
      routingCallback: (routing) {
        if (routing != null) {
          print(
              '>>> ROUTE DEĞİŞİMİ: ${routing.current} → ${routing.route?.settings.name}');
        }
      },

      // Temaları ata
      theme: AppTheme.lightTheme,
      //darkTheme: AppTheme.darkTheme, // Koyu tema (isteğe bağlı)
      themeMode: ThemeMode.system,

      // Splash Screen'den başla
      initialRoute: AppPages.INITIAL_ROUTE,
      getPages: AppPages.routes, // Rota listesi

      // İlk bağlamaları yükle (main.dart'tan önce InitialBinding.dependencies() çağrıldı)
      initialBinding: BindingsBuilder(() {
        print('>>> GetMaterialApp initialBinding çağrıldı');
      }),

      defaultTransition: Transition.fadeIn,
      locale: Locale('tr', 'TR'), // Yerelleştirme için dil ve bölge
      supportedLocales: [
        Locale('en', 'US'),
        Locale('tr', 'TR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
