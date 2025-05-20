import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/app/core/di/service_bindings.dart';
import 'package:mobile/app/data/datasources/local/auth_local_datasource.dart';
import 'package:mobile/app/data/datasources/local/auth_local_datasource_impl.dart';
import 'package:mobile/app/data/datasources/remote/account_remote_datasource.dart';
import 'package:mobile/app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:mobile/app/data/datasources/remote/budget_remote_datasource.dart';
import 'package:mobile/app/data/datasources/remote/category_remote_datasource.dart';
import 'package:mobile/app/data/datasources/remote/debt_payment_remote_datasource.dart';
import 'package:mobile/app/data/datasources/remote/debt_remote_datasource.dart';
import 'package:mobile/app/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/repositories/account_repository_impl.dart';
import 'package:mobile/app/data/repositories/auth_repository_impl.dart';
import 'package:mobile/app/data/repositories/budget_repository_impl.dart';
import 'package:mobile/app/data/repositories/category_repository_impl.dart';
import 'package:mobile/app/data/repositories/debt_payment_repository_impl.dart';
import 'package:mobile/app/data/repositories/debt_repository_impl.dart';
import 'package:mobile/app/data/repositories/transaction_repository_impl.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/domain/repositories/debt_payment_repository.dart';
import 'package:mobile/app/domain/repositories/debt_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';

/// Uygulama başlangıcında yüklenecek genel ve kalıcı bağımlılıkları tanımlar.
/// Bu binding, main.dart'taki GetMaterialApp içinde initialBinding olarak kullanılır.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> InitialBinding dependencies() called');

    // 1. Core Services
    _registerCoreServices();

    // 2. DataSources
    _registerDataSources();

    // 3. Repositories
    _registerRepositories();
  }

  /// Temel servis bağımlılıklarını kaydeder
  void _registerCoreServices() {
    // FlutterSecureStorage (yerel güvenli depolama)
    // Herhangi bir platformda sorun olmaması için basit konfigürasyon kullanıyoruz
    try {
      // Daha güvenli bir storage oluştur
      final secureStorage = const FlutterSecureStorage(
        // Windows için sorun çıkarsa varsayılan ayarları kullan
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

      Get.put<FlutterSecureStorage>(
        secureStorage,
        permanent: true,
      );
      print('>>> FlutterSecureStorage registered with custom options');
    } catch (e) {
      print('>>> Error configuring FlutterSecureStorage: $e');
      // Fallback olarak standart konfigürasyonu kullan
      Get.put<FlutterSecureStorage>(
        const FlutterSecureStorage(),
        permanent: true,
      );
      print('>>> FlutterSecureStorage registered with default options');
    }

    // DioClient (HTTP istemcisi)
    Get.put<DioClient>(
      DioClient(),
      permanent: true,
    );
    print('>>> DioClient registered');

    // NavigationServices
    ServiceBindings().dependencies();
  }

  /// DataSource bağımlılıklarını kaydeder
  void _registerDataSources() {
    // Auth Local DataSource
    Get.lazyPut<IAuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(Get.find<FlutterSecureStorage>()),
      fenix: true,
    );

    // Remote DataSources
    Get.lazyPut<IAuthRemoteDataSource>(
      () => AuthRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );

    Get.lazyPut<IAccountRemoteDataSource>(
      () => AccountRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );

    Get.lazyPut<ITransactionRemoteDataSource>(
      () => TransactionRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );

    Get.lazyPut<ICategoryRemoteDataSource>(
      () => CategoryRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );

    Get.lazyPut<IBudgetRemoteDataSource>(
      () => BudgetRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );

    Get.lazyPut<IDebtRemoteDataSource>(
      () => DebtRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );

    Get.lazyPut<IDebtPaymentRemoteDataSource>(
      () => DebtPaymentRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );

    print('>>> All DataSources registered');
  }

  /// Tüm repository bağımlılıklarını kaydeder
  void _registerRepositories() {
    // Auth Repository
    Get.lazyPut<IAuthRepository>(
      () => AuthRepositoryImpl(
        Get.find<IAuthRemoteDataSource>(),
        Get.find<IAuthLocalDataSource>(),
      ),
      fenix: true,
    );

    // Account Repository
    Get.lazyPut<IAccountRepository>(
      () => AccountRepositoryImpl(
        Get.find<IAccountRemoteDataSource>(),
      ),
      fenix: true,
    );

    // Transaction Repository
    Get.lazyPut<ITransactionRepository>(
      () => TransactionRepositoryImpl(
        Get.find<ITransactionRemoteDataSource>(),
      ),
      fenix: true,
    );

    // Category Repository
    Get.lazyPut<ICategoryRepository>(
      () => CategoryRepositoryImpl(
        Get.find<ICategoryRemoteDataSource>(),
      ),
      fenix: true,
    );

    // Budget Repository
    Get.lazyPut<IBudgetRepository>(
      () => BudgetRepositoryImpl(
        Get.find<IBudgetRemoteDataSource>(),
      ),
      fenix: true,
    );

    // Debt Repository
    Get.lazyPut<IDebtRepository>(
      () => DebtRepositoryImpl(
        Get.find<IDebtRemoteDataSource>(),
      ),
      fenix: true,
    );

    // Debt Payment Repository
    Get.lazyPut<IDebtPaymentRepository>(
      () => DebtPaymentRepositoryImpl(
        Get.find<IDebtPaymentRemoteDataSource>(),
      ),
      fenix: true,
    );

    print('>>> All Repositories registered');
  }
}
