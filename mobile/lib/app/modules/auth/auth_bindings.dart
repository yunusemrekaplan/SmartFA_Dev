import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/datasources/local/auth_local_datasource.dart';
import 'package:mobile/app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/repositories/auth_repository_impl.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/modules/auth/login/login_controller.dart';

import 'register/register_controller.dart';

/// Auth modülü için bağımlılıkları (dependency injection) yönetir.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // --- Data Katmanı Bağımlılıkları ---

    // FlutterSecureStorage (Singleton olarak kaydedilebilir veya her seferinde oluşturulabilir)
    // Get.put() ile singleton olarak kaydetmek genellikle daha iyidir.
    // Eğer başka bir yerde zaten kaydedildiyse Get.find() kullanılabilir.
    // Şimdilik her binding'de oluşturuyoruz:
    Get.lazyPut<FlutterSecureStorage>(() => const FlutterSecureStorage(),
        fenix: true); // fenix: true ile yeniden oluşturulabilir

    // AuthLocalDataSource
    // FlutterSecureStorage'ı inject eder.
    Get.lazyPut<IAuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(Get.find<FlutterSecureStorage>()),
        fenix: true);

    // DioClient (Eğer singleton olarak kaydedilmediyse)
    // Genellikle InitialBinding gibi genel bir binding'de singleton olarak kaydedilir.
    // Varsayım: DioClient zaten singleton veya başka bir binding'de kaydedildi.
    // Get.lazyPut<DioClient>(() => DioClient(), fenix: true); // Eğer kaydedilmediyse

    // AuthRemoteDataSource
    // DioClient'ı inject eder.
    Get.lazyPut<IAuthRemoteDataSource>(() => AuthRemoteDataSource(Get.find<DioClient>()),
        fenix: true);

    // --- Domain Katmanı Bağımlılıkları ---

    // AuthRepository
    // IAuthRemoteDataSource ve IAuthLocalDataSource'u inject eder.
    Get.lazyPut<IAuthRepository>(
        () =>
            AuthRepositoryImpl(Get.find<IAuthRemoteDataSource>(), Get.find<IAuthLocalDataSource>()),
        fenix: true);

    // --- Presentation Katmanı (Controller) Bağımlılıkları ---

    // LoginController
    // IAuthRepository'yi inject eder.
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);

    // RegisterController
    // IAuthRepository'yi inject eder.
    Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);
  }
}
