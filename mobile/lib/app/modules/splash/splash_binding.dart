import 'package:get/get.dart';
import 'package:mobile/app/data/datasources/local/auth_local_datasource.dart';
import 'package:mobile/app/modules/splash/splash_controller.dart';

/// Splash ekranı için binding sınıfı
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> SplashBinding dependencies() çağrıldı');

    // Splash Controller için gerekli bağımlılıkları enjekte ediyoruz
    try {
      // Eager loading - controller'ın hemen oluşturulması için put kullanıyoruz
      // lazyPut yerine put kullanarak hemen oluşturuluyor
      Get.put<SplashController>(
        SplashController(
          authLocalDataSource: Get.find<IAuthLocalDataSource>(),
        ),
        permanent: false,
      );
      print('>>> SplashController başarıyla kaydedildi');
    } catch (e) {
      print('>>> SplashController kaydedilirken hata: $e');
    }
  }
}
