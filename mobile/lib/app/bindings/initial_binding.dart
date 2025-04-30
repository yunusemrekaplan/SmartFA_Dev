import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/app/data/network/dio_client.dart';

/// Uygulama başlangıcında yüklenecek genel ve kalıcı bağımlılıkları tanımlar.
/// Bu binding, main.dart'taki GetMaterialApp içinde initialBinding olarak kullanılır.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> InitialBinding dependencies() called'); // Yüklendiğini görmek için log

    // FlutterSecureStorage'ı singleton (tek örnek) ve kalıcı olarak kaydet.
    // 'permanent: true' ile bu bağımlılık uygulama boyunca hafızada kalır.
    Get.put<FlutterSecureStorage>(
      const FlutterSecureStorage(
          // Opsiyonel: Android için şifreleme seçenekleri
          // aOptions: AndroidOptions(
          //   encryptedSharedPreferences: true,
          // ),
          ),
      permanent: true,
    );
    print('>>> FlutterSecureStorage registered');

    // DioClient'ı singleton (tek örnek) ve kalıcı olarak kaydet.
    // DioClient constructor'ı içinde interceptor'lar dahil Dio instance'ı oluşturulur.
    Get.put<DioClient>(
      DioClient(), // DioClient'ın kendi singleton yapısı varsa veya doğrudan instance
      permanent: true,
    );
    print('>>> DioClient registered');

    // Uygulama genelinde kullanılacak başka kalıcı servisler veya
    // repository'ler varsa burada Get.put(..., permanent: true) ile kaydedilebilir.
    // Örn: Get.put<ISettingsRepository>(SettingsRepositoryImpl(...), permanent: true);
  }
}
