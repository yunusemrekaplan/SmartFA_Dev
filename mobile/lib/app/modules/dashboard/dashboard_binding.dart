import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/modules/dashboard/dashboard_controller.dart';

/// Dashboard modülü için bağımlılıkları yönetir.
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> DashboardBinding dependencies() called');

    // --- Repository Bağımlılıkları ---
    // Bu repository'lerin daha önce HomeBinding veya InitialBinding içinde
    // kaydedildiğini varsayıyoruz. Eğer kaydedilmediyse burada lazyPut ile eklenebilir.
    // Örnek: Get.lazyPut<IAccountRepository>(() => AccountRepositoryImpl(Get.find()), fenix: true);

    // --- Controller Bağımlılığı ---
    // DashboardController'ı kaydet ve gerekli repository'leri inject et.
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        // Get.find() ile önceden kaydedilmiş repository'leri bul ve inject et
        accountRepository: Get.find<IAccountRepository>(),
        transactionRepository: Get.find<ITransactionRepository>(),
        budgetRepository: Get.find<IBudgetRepository>(),
        // debtRepository: Get.find<IDebtRepository>(), // Gerekirse
      ),
      fenix: true, // Ekrandan çıkıldığında silinip tekrar girildiğinde oluşturulsun
    );
  }
}
