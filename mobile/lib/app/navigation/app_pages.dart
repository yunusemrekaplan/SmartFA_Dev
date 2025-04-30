import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/accounts/accounts_binding.dart';
import 'package:mobile/app/modules/transactions/transactions_binding.dart';

// Rota isimlerini import et
import 'app_routes.dart';

// Oluşturulan Ekran ve Binding Importları
import '../modules/auth/login/login_screen.dart';
import '../modules/auth/register/register_screen.dart';
import '../modules/auth/auth_bindings.dart'; // AuthBinding

import '../modules/home/home_screen.dart'; // HomeScreen
import '../modules/home/home_binding.dart'; // HomeBinding (Sadeleşmiş)

// Ekle/Düzenle ekranları için Binding'ler
// import '../modules/accounts/add_edit_account/add_edit_account_binding.dart';
// import '../modules/transactions/add_edit_transaction/add_edit_transaction_binding.dart';
// import '../modules/budgets/add_edit_budget/add_edit_budget_binding.dart';
// import '../modules/debts/add_edit_debt/add_edit_debt_binding.dart';
// import '../modules/debts/add_debt_payment/add_debt_payment_binding.dart';

// Uygulama sayfalarını ve başlangıç rotasını tanımlayan sınıf
class AppPages {
  AppPages._(); // Private constructor

  // Başlangıç Rotası
  static const INITIAL_ROUTE = AppRoutes.LOGIN; // Uygulama Login ile başlasın

  // Rota listesi
  static final routes = [
    // --- Auth Rotaları ---
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      binding: AuthBinding(), // AuthBinding Login ve Register için
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
      binding: AuthBinding(), // AuthBinding Login ve Register için
      transition: Transition.rightToLeft,
    ),

    // --- Ana Rota ---
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeScreen(),
      // HomeBinding sadece HomeController'ı ve belki genel bağımlılıkları yükler.
      // Alt ekranların (Dashboard, Accounts vb.) kendi binding'leri olacak
      // ve bunlar HomeScreen içindeki IndexedStack'e ekranlar eklenirken
      // veya GetX'in nested navigation'ı kullanılırsa tanımlanır.
      // Şimdilik HomeBinding yeterli, çünkü alt controller'lar kendi binding'lerinde
      // lazyPut ile kaydediliyor ve Get.find() ile bulunabiliyorlar.
      binding: HomeBinding(),
    ),

    // --- Detay/Ekleme/Düzenleme Rotaları ---
    // Bu rotalara gidildiğinde ilgili Binding'in çalışması önemlidir.
    GetPage(
      name: AppRoutes.ADD_EDIT_TRANSACTION,
      page: () => const PlaceholderScreen(routeName: 'İşlem Ekle/Düzenle'),
      binding: TransactionsBinding(), // İşlemle ilgili bağımlılıklar
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.ADD_EDIT_ACCOUNT,
      page: () => const PlaceholderScreen(routeName: 'Hesap Ekle/Düzenle'),
      binding: AccountsBinding(), // Hesapla ilgili bağımlılıklar
      fullscreenDialog: true,
    ),
    /*GetPage(
      name: AppRoutes.ADD_EDIT_BUDGET,
      page: () => const PlaceholderScreen(routeName: 'Bütçe Ekle/Düzenle'),
      binding: BudgetsBinding(), // Bütçeyle ilgili bağımlılıklar
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.ADD_EDIT_DEBT,
      page: () => const PlaceholderScreen(routeName: 'Borç Ekle/Düzenle'),
      binding: DebtsBinding(), // Borçla ilgili bağımlılıklar
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.ADD_DEBT_PAYMENT,
      page: () => const PlaceholderScreen(routeName: 'Borç Ödemesi Ekle'),
      binding: DebtsBinding(), // Borç ödemesi de DebtsBinding altında olabilir
      fullscreenDialog: true,
    ),*/

    // --- Ayarlar Alt Rotaları ---
    // Ayarlar ekranı Home içindeki bir sekme olduğu için ayrı route'a gerek yok.
    // Ancak altındaki sayfalar için route tanımlanabilir.
    /*GetPage(
      name: AppRoutes.CATEGORIES, // Kategori Yönetimi
      page: () => const PlaceholderScreen(routeName: 'Kategori Yönetimi'),
      binding: CategoriesBinding(), // Kategori bağımlılıkları
    ),
    GetPage(
      name: AppRoutes.PROFILE, // Profil Ekranı
      page: () => const PlaceholderScreen(routeName: 'Profil'),
      binding: ProfileBinding(), // Profil bağımlılıkları
    ),
    // Borçlar ekranı Ayarlar altından da erişilebilir, ayrı route'u olabilir.
    GetPage(
      name: AppRoutes.DEBTS,
      page: () => const PlaceholderScreen(routeName: 'Borç Yönetimi'),
      binding: DebtsBinding(),
    ),*/

    // Splash Ekranı (Opsiyonel)
    // GetPage(name: AppRoutes.SPLASH, page: () => SplashScreen(), binding: SplashBinding()),
  ];
}

// Yer tutucu widget (Tekrar tanımlamaya gerek yok, önceki kodda vardı)
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
