import 'package:get/get.dart';
import 'package:mobile/app/data/datasources/remote/budget_remote_datasource.dart';
import 'package:mobile/app/data/datasources/remote/category_remote_datasource.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/repositories/budget_repository_impl.dart';
import 'package:mobile/app/data/repositories/category_repository_impl.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/modules/budgets/controllers/budget_add_edit_controller.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/modules/budgets/services/budget_add_edit/budget_validation_service.dart';

/// Budgets modülü için bağımlılıkları yönetir.
/// DI (Dependency Injection) ve DIP (Dependency Inversion Principle) prensiplerine uygun
class BudgetsBinding extends Bindings {
  @override
  void dependencies() {
    _registerDataSources();
    _registerRepositories();
    _registerServices();
    _registerControllers();
  }

  /// Data kaynakları kayıt işlemleri
  void _registerDataSources() {
    // RemoteDataSource bağımlılıkları
    Get.lazyPut<IBudgetRemoteDataSource>(
      () => BudgetRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );

    Get.lazyPut<ICategoryRemoteDataSource>(
      () => CategoryRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );
  }

  /// Repository bağımlılıkları
  void _registerRepositories() {
    // Repository bağımlılıkları
    Get.lazyPut<IBudgetRepository>(
      () => BudgetRepositoryImpl(Get.find<IBudgetRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<ICategoryRepository>(
      () => CategoryRepositoryImpl(Get.find<ICategoryRemoteDataSource>()),
      fenix: true,
    );
  }

  /// Servis bağımlılıkları
  void _registerServices() {
    // Servisleri kaydet
    Get.lazyPut<BudgetValidationService>(
      () => BudgetValidationService(),
      fenix: true,
    );
  }

  /// Controller bağımlılıkları
  void _registerControllers() {
    // Ana Controller - Bütçe listesi
    Get.lazyPut<BudgetsController>(
      () => BudgetsController(
        budgetRepository: Get.find<IBudgetRepository>(),
      ),
      fenix: true,
    );

    // Ekleme/Düzenleme Controller - Her kullanımda yenisi oluşturulur
    Get.lazyPut<BudgetAddEditController>(
      () => BudgetAddEditController(
        Get.find<IBudgetRepository>(),
        Get.find<ICategoryRepository>(),
      ),
      fenix: false, // Her seferinde yeni instance oluşturulsun
    );
  }
}
