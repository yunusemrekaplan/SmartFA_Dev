import 'package:get/get.dart';

// Controller importu (henüz oluşturulmadı)
import 'transactions_controller.dart';

// Repository Arayüzü ve Implementasyonu importları
import '../../domain/repositories/transaction_repository.dart';
import '../../data/repositories/transaction_repository_impl.dart';
// Hesap ve Kategori repository'leri de gerekebilir (filtreleme için)
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';


// DataSource importu (Repository için gerekli)
import '../../data/datasources/remote/transaction_remote_datasource.dart';
import '../../data/datasources/remote/account_remote_datasource.dart'; // Gerekli
import '../../data/datasources/remote/category_remote_datasource.dart'; // Gerekli


// DioClient importu (DataSource için gerekli - InitialBinding'de kaydedildi)
import '../../data/network/dio_client.dart';


/// Transactions modülü için bağımlılıkları yönetir.
class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> TransactionsBinding dependencies() called');

    // --- Data Katmanı Bağımlılıkları ---
    // DataSource'lar (Eğer Initial/Home binding'de değilse)
    Get.lazyPut<ITransactionRemoteDataSource>(() => TransactionRemoteDataSource(Get.find<DioClient>()), fenix: true);
    // Hesap ve Kategori DataSource'ları diğer binding'lerde zaten olabilir,
    // ama burada da lazyPut ile eklemek sorun çıkarmaz (GetX yönetir).
    Get.lazyPut<IAccountRemoteDataSource>(() => AccountRemoteDataSource(Get.find<DioClient>()), fenix: true);
    Get.lazyPut<ICategoryRemoteDataSource>(() => CategoryRemoteDataSource(Get.find<DioClient>()), fenix: true);


    // --- Domain Katmanı Bağımlılıkları (Repositories) ---
    Get.lazyPut<ITransactionRepository>(() => TransactionRepositoryImpl(Get.find<ITransactionRemoteDataSource>()), fenix: true);
    Get.lazyPut<IAccountRepository>(() => AccountRepositoryImpl(Get.find<IAccountRemoteDataSource>()), fenix: true);
    Get.lazyPut<ICategoryRepository>(() => CategoryRepositoryImpl(Get.find<ICategoryRemoteDataSource>()), fenix: true);


    // --- Presentation Katmanı (Controller) Bağımlılığı ---
    // TransactionsController'ı kaydet ve gerekli Repository'leri inject et.
    Get.lazyPut<TransactionsController>(
          () => TransactionsController(
        transactionRepository: Get.find<ITransactionRepository>(),
        accountRepository: Get.find<IAccountRepository>(), // Filtreleme için hesap listesi gerekebilir
        categoryRepository: Get.find<ICategoryRepository>(), // Filtreleme için kategori listesi gerekebilir
      ),
      fenix: true,
    );
  }
}
