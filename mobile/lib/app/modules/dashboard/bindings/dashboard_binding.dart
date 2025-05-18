import 'package:get/get.dart';

import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';

/// Dashboard modülü için bağımlılıkları yönetir.
/// Controller'a gerekli repository'leri enjekte eder, servisler controller içinde oluşturulur.
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> DashboardBinding dependencies() called');

    // --- Repository Bağımlılıkları ---
    // Bu repository'lerin daha önce HomeBinding veya InitialBinding içinde
    // kaydedildiğini varsayıyoruz. Eğer kaydedilmediyse burada lazyPut ile eklenebilir.
    // Örnek: Get.lazyPut<IAccountRepository>(() => AccountRepositoryImpl(Get.find()), fenix: true);

    // Eğer error handler enjekte edilmemişse
    if (!Get.isRegistered<ErrorHandler>()) {
      Get.lazyPut<ErrorHandler>(() => ErrorHandler(), fenix: true);
    }

    // --- Controller Bağımlılığı ---
    // DashboardController'ı kaydet. Controller içinde servisler oluşturulacak.
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        // Get.find() ile önceden kaydedilmiş repository'leri bul ve inject et
        accountRepository: Get.find<IAccountRepository>(),
        transactionRepository: Get.find<ITransactionRepository>(),
        budgetRepository: Get.find<IBudgetRepository>(),
        errorHandler: Get.find<ErrorHandler>(),
      ),
      fenix:
          true, // Ekrandan çıkıldığında silinip tekrar girildiğinde oluşturulsun
    );
  }
}
