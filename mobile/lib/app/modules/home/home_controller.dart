import 'package:get/get.dart';

/// HomeScreen'in state'ini (özellikle aktif sekme index'ini) yönetir.
class HomeController extends GetxController {
  // BottomNavigationBar'daki seçili sekmenin index'ini tutan reaktif değişken.
  // Başlangıçta ilk sekme (örn: Dashboard) seçili olsun (index 0).
  final RxInt selectedIndex = 0.obs;

  /// Sekme değiştirildiğinde çağrılacak metot.
  /// BottomNavigationBar'ın onTap event'i tarafından kullanılır.
  void changeTabIndex(int index) {
    selectedIndex.value = index;
    // İsteğe bağlı: Sekme değiştiğinde ek işlemler yapılabilir
    // (örn: ilgili controller'ı başlatma, veri yenileme vb.)
    print('Selected Tab Index: $index'); // Debug log
  }

// Bu controller'a daha sonra başka state'ler veya metotlar eklenebilir
// (örn: genel bir refresh metodu, kullanıcı bilgileri vb.)
}
