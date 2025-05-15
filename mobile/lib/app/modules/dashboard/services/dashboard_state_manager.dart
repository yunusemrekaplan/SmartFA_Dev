import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/home/home_controller.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';
import 'package:mobile/app/data/network/exceptions.dart';

/// Dashboard ekranının UI durumunu yöneten servis sınıfı.
/// Yükleme, hata durumları ve navigasyon işlevlerini yönetir.
class DashboardStateManager {
  // Bağımlılıklar
  final ErrorHandler _errorHandler;

  // UI durum değişkenleri
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Constructor - Dependency Injection
  DashboardStateManager({
    ErrorHandler? errorHandler,
  }) : _errorHandler = errorHandler ?? ErrorHandler();

  /// Yükleme durumunu ayarlar
  void setLoadingState(bool loading) {
    // Eğer yükleme durumu false ise, her zaman güncellemek için izin ver
    // (yükleme durumunun sonlandırılması kritik öneme sahiptir)
    if (!loading || isLoading.value != loading) {
      isLoading.value = loading;
    }
  }

  /// Hata mesajını temizler
  void clearErrorMessage() {
    errorMessage.value = '';
  }

  /// Beklenmedik hataları yakalar ve kullanıcıya gösterir
  void handleUnexpectedError(dynamic error) {
    print('>>> DashboardStateManager Unexpected Error: $error');
    errorMessage.value =
        'Dashboard verileri yüklenirken beklenmedik bir hata oluştu.';
    // Hata durumunda yükleme göstergesini kapat
    setLoadingState(false);
  }

  /// Hataları ErrorHandler ile işleyip hata mesajı oluşturur
  void handleError(AppException error, String title, VoidCallback onRetry) {
    // Hata durumunda yükleme göstergesini kapat
    setLoadingState(false);

    _errorHandler.handleError(
      error,
      message: 'Dashboard verileri yüklenirken bir hata oluştu.',
      onRetry: onRetry,
      customTitle: title,
    );
  }

  /// Hesaplar sayfasına yönlendirir
  void navigateToAccounts() {
    try {
      Get.find<HomeController>().changeTabIndex(1);
    } catch (e) {
      _navigateByRoute(AppRoutes.ACCOUNTS);
    }
  }

  /// Bütçeler sayfasına yönlendirir
  void navigateToBudgets() {
    try {
      Get.find<HomeController>().changeTabIndex(3);
    } catch (e) {
      _navigateByRoute(AppRoutes.BUDGETS);
    }
  }

  /// İşlemler sayfasına yönlendirir
  void navigateToTransactions() {
    try {
      Get.find<HomeController>().changeTabIndex(2);
    } catch (e) {
      _navigateByRoute(AppRoutes.TRANSACTIONS);
    }
  }

  /// Finansal analiz sayfasına yönlendirir (henüz yapım aşamasında)
  void navigateToAnalysis() {
    _showFeatureInDevelopmentMessage();
  }

  /// Belirtilen rotaya yönlendirir
  void _navigateByRoute(String route) {
    Get.toNamed(route);
  }

  /// "Yapım aşamasında" mesajı gösterir
  void _showFeatureInDevelopmentMessage() {
    Get.snackbar(
      'Yapım Aşamasında',
      'Detaylı finans analizi yakında kullanıma sunulacak!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
