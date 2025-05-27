import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/auth_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';
import 'dart:async';

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

  /// Loading timeout timer
  Timer? _loadingTimeoutTimer;

  /// Loading başlangıç zamanı
  DateTime? _loadingStartTime;

  /// Maximum loading süresi (milliseconds)
  static const int _maxLoadingDuration = 30000; // 30 saniye

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    errorMessage.value = '';
    ever(isLoading, _onLoadingChanged);
  }

  @override
  void onClose() {
    _loadingTimeoutTimer?.cancel();
    super.onClose();
  }

  /// Yükleme durumu değiştiğinde yapılacak işlemler
  void _onLoadingChanged(bool loading) {
    _logDebug('Yükleme durumu değişti: $loading');

    if (loading) {
      _loadingStartTime = DateTime.now();
      _startLoadingTimeout();
    } else {
      _loadingTimeoutTimer?.cancel();
      _loadingStartTime = null;
    }
  }

  /// Loading timeout başlatır
  void _startLoadingTimeout() {
    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(
      const Duration(milliseconds: _maxLoadingDuration),
      () {
        if (isLoading.value) {
          _logDebug('Loading timeout reached, forcing loading to false');
          isLoading.value = false;
          errorMessage.value =
              'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
        }
      },
    );
  }

  /// Loading state'i güvenli şekilde ayarlar
  void setLoadingState(bool loading, {String? message}) {
    if (loading) {
      errorMessage.value = '';
    }
    isLoading.value = loading;

    if (message != null && !loading) {
      errorMessage.value = message;
    }
  }

  /// Loading state'i zorla kapatır (token yenileme sonrası için)
  void forceStopLoading({String? errorMsg}) {
    _loadingTimeoutTimer?.cancel();
    isLoading.value = false;
    _loadingStartTime = null;

    if (errorMsg != null) {
      errorMessage.value = errorMsg;
    }
  }

  /// Veri yükleme işlemini standart hata yönetimi ile gerçekleştirir
  Future<void> loadData({
    required Future<void> Function() fetchFunc,
    String? loadingErrorMessage,
    VoidCallback? onSuccess,
    Function(dynamic)? onError,
    bool preventMultipleRequests = true,
    Duration? customTimeout,
  }) async {
    if (isLoading.value && preventMultipleRequests) {
      _logDebug('Veri yükleme zaten devam ediyor, yeni istek engellendi');
      return;
    }

    setLoadingState(true);

    try {
      // Özel timeout varsa kullan
      if (customTimeout != null) {
        await fetchFunc().timeout(customTimeout);
      } else {
        await fetchFunc();
      }

      if (onSuccess != null) onSuccess();
    } on TimeoutException {
      _handleError(Exception('Timeout'),
          'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.');
      if (onError != null) onError('Timeout');
    } on AuthException catch (e) {
      // Auth hatalarında loading'i zorla kapat
      forceStopLoading(errorMsg: e.message);
      if (onError != null) onError(e);
    } catch (e) {
      _handleError(
          e, loadingErrorMessage ?? 'Veriler yüklenirken bir hata oluştu');
      if (onError != null) onError(e);
    } finally {
      // Auth exception dışındaki durumlarda normal kapatma
      if (!errorMessage.value.contains('Oturum') &&
          !errorMessage.value.contains('yetki')) {
        setLoadingState(false);
      }
    }
  }

  /// Hata durumlarını standart şekilde işler
  void _handleError(dynamic error, String fallbackMessage) {
    String message = fallbackMessage;

    if (error is AppException) {
      message = error.message;
      _errorHandler.handleError(error, message: message);
    } else if (error is Exception) {
      _logDebug('Beklenmedik hata: $error');
      _errorHandler.handleError(
        UnexpectedException(message: message, details: error),
        message: message,
      );
    } else {
      _logDebug('Bilinmeyen hata tipi: $error');
      _errorHandler.handleError(
        UnexpectedException(message: message, details: error),
        message: message,
      );
    }

    errorMessage.value = message;
  }

  /// Debug loglaması
  void _logDebug(String message) {
    if (kDebugMode) {
      print('>>> BaseControllerMixin: $message');
    }
  }

  /// Hata mesajını temizler
  void clearError() {
    errorMessage.value = '';
  }

  /// Loading süresini kontrol eder
  Duration? get loadingDuration {
    if (_loadingStartTime != null) {
      return DateTime.now().difference(_loadingStartTime!);
    }
    return null;
  }

  /// Loading'in çok uzun sürdüğünü kontrol eder
  bool get isLoadingTooLong {
    final duration = loadingDuration;
    return duration != null && duration.inMilliseconds > 10000; // 10 saniye
  }
}
