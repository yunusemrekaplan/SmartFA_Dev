import 'package:get/get.dart';
import 'package:mobile/app/modules/home/home_controller.dart';

/// Sadece HomeScreen ve genel home yapısı için bağımlılıkları yönetir.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> HomeBinding dependencies() called');

    // Ana Home Controller (BottomNavBar yönetimi, genel home state'i vb. için)
    // Bu controller, diğer sekmelerin controller'larına erişebilir veya
    // sekme değişimini yönetebilir.
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
