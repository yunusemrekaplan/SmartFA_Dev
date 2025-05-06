import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/accounts/bindings/add_edit_account_binding.dart';
import 'package:mobile/app/modules/accounts/views/add_edit_account_screen.dart';
import 'package:mobile/app/modules/budgets/bindings/add_edit_budget_binding.dart';
import 'package:mobile/app/modules/budgets/bindings/budgets_binding.dart';
import 'package:mobile/app/modules/budgets/views/add_edit_budget_screen.dart';
import 'package:mobile/app/modules/budgets/views/budgets_screen.dart';
import 'package:mobile/app/modules/splash/splash_binding.dart';
import 'package:mobile/app/modules/splash/splash_screen.dart';
import 'package:mobile/app/modules/transactions/bindings/add_edit_transaction_binding.dart';
import 'package:mobile/app/modules/transactions/views/add_edit_transaction_screen.dart';

// Rota isimlerini import et
import 'app_routes.dart';

// Oluşturulan Ekran ve Binding Importları
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/register_screen.dart';
import '../modules/auth/auth_bindings.dart'; // AuthBinding

import '../modules/home/home_screen.dart'; // HomeScreen
import '../modules/home/home_binding.dart'; // HomeBinding (Sadeleşmiş)

// Ekle/Düzenle ekranları için Binding'ler
// import '../modules/accounts/add_edit_account/add_edit_account_binding.dart';
// import '../modules/budgets/add_edit_budget/add_edit_budget_binding.dart';
// import '../modules/debts/add_edit_debt/add_edit_debt_binding.dart';
// import '../modules/debts/add_debt_payment/add_debt_payment_binding.dart';

// Uygulama sayfalarını ve başlangıç rotasını tanımlayan sınıf
class AppPages {
  AppPages._(); // Private constructor

  // Başlangıç Rotası
  static const INITIAL_ROUTE = AppRoutes.SPLASH; // Uygulama Splash ile başlasın

  // Rota listesi
  static final routes = [
    // --- Splash Screen ---
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      preventDuplicates: true,
      // Aynı rotaya birden fazla gidilmesini engelle
      popGesture: false,
      // Geri gitme hareketini engelle
      transitionDuration: const Duration(milliseconds: 500),
    ),

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
      page: () => const AddEditTransactionScreen(),
      binding: AddEditTransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.ADD_EDIT_ACCOUNT,
      page: () => const AddEditAccountScreen(),
      binding: AddEditAccountBinding(), // Hesapla ilgili bağımlılıklar
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.BUDGETS,
      page: () => const BudgetsScreen(),
      binding: BudgetsBinding(), // Bütçeyle ilgili bağımlılıklar
    ),
    GetPage(
      name: AppRoutes.ADD_EDIT_BUDGET,
      page: () => const AddEditBudgetScreen(),
      binding: AddEditBudgetBinding(), // Bütçe ekleme/düzenleme bağımlılıkları
      fullscreenDialog: true,
    ),
    /*GetPage(
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
