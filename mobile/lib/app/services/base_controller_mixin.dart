import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile/app/services/page_refresh_service.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/error_handler.dart';

/// Tüm controller'lar için standart veri yükleme, yenileme ve hata yönetimi
/// işlevlerini sağlayan mixin.
///
/// Bu mixin, controller'larda veri yükleme ve yenileme işlemlerini
/// standartlaştırmak için kullanılır. Her controller yükleme ve hata
/// durumlarını aynı şekilde yönetir.
mixin RefreshableControllerMixin on GetxController {
  /// Yükleme durumu göstergesi
  late final RxBool isLoading = false.obs;

  /// Hata mesajı (boş string yoksa hata olmadığını gösterir)
  late final RxString errorMessage = ''.obs;

  /// Hata işleyici
  late final ErrorHandler _errorHandler = Get.find<ErrorHandler>();

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    errorMessage.value = '';
    ever(isLoading, _onLoadingChanged);
  }

  /// Yükleme durumu değiştiğinde yapılacak işlemler
  void _onLoadingChanged(bool loading) {
    _logDebug('Yükleme durumu değişti: $loading');
  }

  /// Veri yükleme işlemini standart hata yönetimi ile gerçekleştirir
  /// [fetchFunc] fonksiyonu asıl veri getirme işlemini yapar
  Future<void> loadData({
    required Future<void> Function() fetchFunc,
    String? loadingErrorMessage,
    VoidCallback? onSuccess,
    Function(dynamic)? onError,
    bool preventMultipleRequests = true,
  }) async {
    // Hali hazırda yükleme yapılıyorsa ve engellemek isteniyorsa, çık
    if (isLoading.value && preventMultipleRequests) {
      _logDebug('Veri yükleme zaten devam ediyor, yeni istek engellendi');
      return;
    }

    await PageRefreshService.refreshWithErrorHandling(
      refreshAction: fetchFunc,
      isLoading: isLoading,
      errorMessage: errorMessage,
      onSuccess: onSuccess,
      onError: (e) {
        _handleError(
            e, loadingErrorMessage ?? 'Veriler yüklenirken bir hata oluştu');
        if (onError != null) onError(e);
      },
    );
  }

  /// Verileri yeniler (genellikle UI'dan, pull-to-refresh ile çağrılır)
  Future<void> refreshData({
    required Future<void> Function() fetchFunc,
    String? refreshErrorMessage,
    VoidCallback? onSuccess,
  }) async {
    await PageRefreshService.refreshWithErrorHandling(
      refreshAction: fetchFunc,
      isLoading: isLoading,
      errorMessage: errorMessage,
      onSuccess: onSuccess,
      onError: (e) => _handleError(
          e, refreshErrorMessage ?? 'Veriler yenilenirken bir hata oluştu'),
    );

    // RefreshIndicator için Future'ı her zaman tamamla
    return Future.value();
  }

  /// Token yenileme sonrası verileri güvenli bir şekilde yeniler
  Future<void> refreshAfterTokenRenewal({
    required Future<void> Function() fetchFunc,
  }) async {
    await PageRefreshService.safeRefreshAfterTokenRefresh(
      refreshAction: fetchFunc,
      isLoading: isLoading,
    );
  }

  /// İlk yükleme ve yenileme işlemlerinde tutarlılık için yükleme durumunu sıfırlar
  void resetLoadingState() {
    isLoading.value = false;
  }

  /// Hata mesajını temizler
  void clearErrorMessage() {
    errorMessage.value = '';
  }

  /// Hataları standart bir şekilde işler
  void _handleError(dynamic error, String defaultMessage) {
    if (error is AppException) {
      // ErrorHandler'ı kullanarak hatayı göster
      _errorHandler.handleError(
        error,
        message: defaultMessage,
        onRetry: () => loadData(
            fetchFunc:
                () async {}), // Boş fonksiyon, alt sınıflarda override edilecek
      );

      // Hata mesajını ayarla
      errorMessage.value = error.message;
    } else {
      // Beklenmeyen hata durumu
      _logDebug('Beklenmeyen hata: $error');
      errorMessage.value = defaultMessage;
    }
  }

  /// Debug modunda log basar
  void _logDebug(String message) {
    if (kDebugMode) {
      print('>>> ${runtimeType.toString()}: $message');
    }
  }
}
