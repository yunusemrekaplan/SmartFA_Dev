import 'package:get/get.dart';
import 'package:mobile/app/data/datasources/remote/account_remote_datasource.dart';
import 'package:mobile/app/data/datasources/remote/category_remote_datasource.dart';
import 'package:mobile/app/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/repositories/account_repository_impl.dart';
import 'package:mobile/app/data/repositories/category_repository_impl.dart';
import 'package:mobile/app/data/repositories/transaction_repository_impl.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/modules/transactions/controllers/add_edit_transaction_controller.dart';

class AddEditTransactionBinding extends Bindings {
  @override
  void dependencies() {
    // DataSource'lar
    Get.lazyPut<ITransactionRemoteDataSource>(
      () => TransactionRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );
    Get.lazyPut<IAccountRemoteDataSource>(
      () => AccountRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );
    Get.lazyPut<ICategoryRemoteDataSource>(
      () => CategoryRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );

    // Repository'ler
    Get.lazyPut<ITransactionRepository>(
      () => TransactionRepositoryImpl(Get.find<ITransactionRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<IAccountRepository>(
      () => AccountRepositoryImpl(Get.find<IAccountRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<ICategoryRepository>(
      () => CategoryRepositoryImpl(Get.find<ICategoryRemoteDataSource>()),
      fenix: true,
    );

    // Controller
    Get.lazyPut<AddEditTransactionController>(
      () => AddEditTransactionController(
        transactionRepository: Get.find<ITransactionRepository>(),
        accountRepository: Get.find<IAccountRepository>(),
        categoryRepository: Get.find<ICategoryRepository>(),
      ),
      fenix: true,
    );
  }
}
