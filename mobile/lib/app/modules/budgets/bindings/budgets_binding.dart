import 'package:get/get.dart';
import 'package:mobile/app/data/datasources/remote/budget_remote_datasource.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/repositories/budget_repository_impl.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';

/// Budgets modülü için bağımlılıkları yönetir.
class BudgetsBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> BudgetsBinding dependencies() called');

    // --- Data Katmanı Bağımlılıkları ---
    // DataSource (Eğer Initial veya Home binding'de değilse)
    Get.lazyPut<IBudgetRemoteDataSource>(
        () => BudgetRemoteDataSource(Get.find<DioClient>()),
        fenix: true);

    // --- Domain Katmanı Bağımlılıkları (Repository) ---
    // Repository (Eğer Initial veya Home binding'de değilse)
    Get.lazyPut<IBudgetRepository>(
        () => BudgetRepositoryImpl(Get.find<IBudgetRemoteDataSource>()),
        fenix: true);

    // --- Presentation Katmanı (Controller) Bağımlılığı ---
    // BudgetsController'ı kaydet ve IBudgetRepository'yi inject et.
    Get.lazyPut<BudgetsController>(
      () => BudgetsController(
        Get.find<IBudgetRepository>(),
      ),
      fenix:
          true, // Ekrandan çıkıldığında silinip tekrar girildiğinde oluşturulsun
    );
  }
}
