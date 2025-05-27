// Rota isimlerini tanımlayan soyut sınıf
abstract class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Ana Rotalar
  static const SPLASH = '/splash'; // Başlangıç ekranı (opsiyonel)
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME =
      '/home'; // Ana ekran (Dashboard ve diğer sekmeleri içerebilir)

  // Diğer Rotalar (Özelliklere göre)
  static const ACCOUNTS =
      '/accounts'; // Hesaplar listesi (HOME içinde bir sekme olabilir)
  static const ACCOUNT_DETAIL = '/account-detail'; // Hesap detayı (opsiyonel)
  static const ADD_EDIT_ACCOUNT = '/add-edit-account';

  static const TRANSACTIONS =
      '/transactions'; // İşlemler listesi (HOME içinde bir sekme olabilir)
  static const TRANSACTION_DETAIL =
      '/transaction-detail'; // İşlem detayı (opsiyonel)
  static const ADD_EDIT_TRANSACTION = '/add-edit-transaction';

  static const BUDGETS =
      '/budgets'; // Bütçeler listesi (HOME içinde bir sekme olabilir)
  static const ADD_EDIT_BUDGET = '/add-edit-budget';

  static const DEBTS =
      '/debts'; // Borçlar listesi (HOME içinde bir sekme olabilir veya Ayarlar altında)
  static const ADD_EDIT_DEBT = '/add-edit-debt';
  static const DEBT_DETAIL =
      '/debt-detail'; // Borç detayı ve ödemeler (opsiyonel)
  static const ADD_DEBT_PAYMENT = '/add-debt-payment';

  static const CATEGORIES =
      '/categories'; // Kategori yönetimi (Ayarlar altında)
  // static const ADD_EDIT_CATEGORY = '/add-edit-category'; // Genellikle modal ile yapılır

  static const SETTINGS =
      '/settings'; // Ayarlar ekranı (HOME içinde bir sekme olabilir)
  static const PROFILE = '/profile'; // Profil düzenleme (Ayarlar altında)
}
