import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Rota isimlerini import et
import 'app_routes.dart';


// Uygulama sayfalarını ve başlangıç rotasını tanımlayan sınıf
class AppPages {
  // Private constructor to prevent instantiation
  AppPages._();


  static const INITIAL_ROUTE = AppRoutes.LOGIN;
  // static const INITIAL_ROUTE = AppRoutes.SPLASH;

  static final routes = [
    // --- Auth Rotaları ---
   /* GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(), // Login ekranı widget'ı
      binding: LoginBinding(), // Login için dependency injection
      transition: Transition.fadeIn, // Geçiş animasyonu (opsiyonel)
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(), // Register ekranı widget'ı
      binding: RegisterBinding(), // Register için dependency injection
      transition: Transition.rightToLeft,
    ),

    // --- Ana Rota (Bottom Nav Bar içeren yapı) ---
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeScreen(), // Ana ekran widget'ı (Dashboard, Hesaplar vb. içerir)
      binding: HomeBinding(), // Ana ekran ve alt sekmelerin binding'leri
      // Alt rotalar (eğer Home içinde farklı sayfalar varsa)
      // children: [
      //   GetPage(name: AppRoutes.DASHBOARD, page:()=> DashboardScreen(), binding: DashboardBinding()),
      //   GetPage(name: AppRoutes.ACCOUNTS, page:()=> AccountsScreen(), binding: AccountsBinding()),
      // ]
    ),*/

    // --- İşlem Rotaları ---
    GetPage(
      name: AppRoutes.ADD_EDIT_TRANSACTION,
      page: () => const PlaceholderScreen(routeName: 'İşlem Ekle/Düzenle'), // Yer tutucu
      // binding: AddEditTransactionBinding(),
      fullscreenDialog: true, // Genellikle modal gibi açılır
    ),

    // --- Hesap Rotaları ---
    GetPage(
      name: AppRoutes.ADD_EDIT_ACCOUNT,
      page: () => const PlaceholderScreen(routeName: 'Hesap Ekle/Düzenle'), // Yer tutucu
      // binding: AddEditAccountBinding(),
      fullscreenDialog: true,
    ),

    // --- Bütçe Rotaları ---
    GetPage(
      name: AppRoutes.ADD_EDIT_BUDGET,
      page: () => const PlaceholderScreen(routeName: 'Bütçe Ekle/Düzenle'), // Yer tutucu
      // binding: AddEditBudgetBinding(),
      fullscreenDialog: true,
    ),

    // --- Borç Rotaları ---
    GetPage(
      name: AppRoutes.ADD_EDIT_DEBT,
      page: () => const PlaceholderScreen(routeName: 'Borç Ekle/Düzenle'), // Yer tutucu
      // binding: AddEditDebtBinding(),
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.ADD_DEBT_PAYMENT,
      page: () => const PlaceholderScreen(routeName: 'Borç Ödemesi Ekle'), // Yer tutucu
      // binding: AddDebtPaymentBinding(),
      fullscreenDialog: true,
    ),

    // --- Ayarlar ve Alt Rotaları ---
    GetPage(
      name: AppRoutes.SETTINGS, // Ayarlar ana ekranı (Home içinde bir sekme değilse)
      page: () => const PlaceholderScreen(routeName: 'Ayarlar'), // Yer tutucu
      // binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.CATEGORIES, // Kategori Yönetimi
      page: () => const PlaceholderScreen(routeName: 'Kategori Yönetimi'), // Yer tutucu
      // binding: CategoriesBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE, // Profil Ekranı
      page: () => const PlaceholderScreen(routeName: 'Profil'), // Yer tutucu
      // binding: ProfileBinding(),
    ),


    // Splash Ekranı (Opsiyonel)
    // GetPage(
    //   name: AppRoutes.SPLASH,
    //   page: () => SplashScreen(),
    //   binding: SplashBinding(),
    // ),

    // Diğer rotalar buraya eklenecek...
  ];
}


// Henüz ekranlar oluşturulmadığı için geçici yer tutucu widget
class PlaceholderScreen extends StatelessWidget {
  final String routeName;
  const PlaceholderScreen({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(routeName)),
      body: Center(
        child: Text('$routeName Ekranı'),
      ),
    );
  }
}
