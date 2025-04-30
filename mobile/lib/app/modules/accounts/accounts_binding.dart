import 'package:get/get.dart';
import 'package:mobile/app/data/datasources/remote/account_remote_datasource.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/repositories/account_repository_impl.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/modules/accounts/accounts_controller.dart';

/// Accounts modülü için bağımlılıkları yönetir.
class AccountsBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> AccountsBinding dependencies() called');

    // --- Data Katmanı Bağımlılıkları ---
    // DataSource (Eğer Initial veya Home binding'de değilse)
    // HomeBinding'de kaydetmiştik, burada tekrar kaydetmeye gerek yok VEYA
    // her özellik kendi bağımlılığını kaydedebilir. İkinci yaklaşımı seçelim:
    Get.lazyPut<IAccountRemoteDataSource>(() => AccountRemoteDataSource(Get.find<DioClient>()),
        fenix: true);

    // --- Domain Katmanı Bağımlılıkları (Repository) ---
    // Repository (Eğer Initial veya Home binding'de değilse)
    Get.lazyPut<IAccountRepository>(
        () => AccountRepositoryImpl(Get.find<IAccountRemoteDataSource>()),
        fenix: true);

    // --- Presentation Katmanı (Controller) Bağımlılığı ---
    // AccountsController'ı kaydet ve IAccountRepository'yi inject et.
    Get.lazyPut<AccountsController>(
      () => AccountsController(
        Get.find<IAccountRepository>(),
      ),
      fenix: true, // Ekrandan çıkıldığında silinip tekrar girildiğinde oluşturulsun
    );
  }
}
