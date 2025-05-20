import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';

/// Tüm controller'lar için standart veri yükleme ve hata yönetimi
/// işlevlerini sağlayan mixin.
///
/// Bu mixin, controller'larda veri yükleme ve hata
/// durumlarını aynı şekilde yönetir.
mixin BaseControllerMixin on GetxController {
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
  Future<void> loadData({
    required Future<void> Function() fetchFunc,
    String? loadingErrorMessage,
    VoidCallback? onSuccess,
    Function(dynamic)? onError,
    bool preventMultipleRequests = true,
  }) async {
    if (isLoading.value && preventMultipleRequests) {
      _logDebug('Veri yükleme zaten devam ediyor, yeni istek engellendi');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await fetchFunc();
      if (onSuccess != null) onSuccess();
    } catch (e) {
      _handleError(
          e, loadingErrorMessage ?? 'Veriler yüklenirken bir hata oluştu');
      if (onError != null) onError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Hata mesajını temizler
  void clearErrorMessage() {
    errorMessage.value = '';
  }

  /// Hataları standart bir şekilde işler
  void _handleError(dynamic error, String defaultMessage) {
    if (error is AppException) {
      _errorHandler.handleError(
        error,
        message: defaultMessage,
        onRetry: () => loadData(fetchFunc: () async {}),
      );
      errorMessage.value = error.message;
    } else {
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
