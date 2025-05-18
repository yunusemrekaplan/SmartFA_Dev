import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Sayfa yenileme işlemlerini uygulama genelinde standartlaştıran servis.
/// Pull-to-refresh, token yenileme, ve genel veri yenileme işlemleri için kullanılır.
class PageRefreshService {
  /// Yenileme işlemi sırasında oluşabilecek hataları yönetir
  static Future<void> refreshWithErrorHandling({
    required Future<void> Function() refreshAction,
    required RxBool isLoading,
    required RxString errorMessage,
    Function? onSuccess,
    Function(dynamic)? onError,
    bool resetLoadingState = true,
    bool clearErrorMessage = true,
  }) async {
    // Halihazırda yükleme yapılıyorsa işlemi engelle
    if (isLoading.value) {
      _logDebug(
          'Yenileme işlemi zaten devam ediyor, yeni istek göz ardı edildi');
      return;
    }

    // Yükleme durumunu başlat
    isLoading.value = true;

    // Hata mesajını temizle (eğer isteniyorsa)
    if (clearErrorMessage) {
      errorMessage.value = '';
    }

    try {
      // Asıl veri yenileme işlemini gerçekleştir
      await refreshAction();

      // Başarılı olunca callback çağır (eğer tanımlanmışsa)
      if (onSuccess != null) {
        onSuccess();
      }

      _logDebug('Veri yenileme işlemi başarıyla tamamlandı');
    } catch (e) {
      // Boş veri durumunu kontrol et
      if (e.toString().contains('No data found')) {
        _logDebug(
            'Boş veri durumu tespit edildi, normal bir durum olarak işleniyor');
        // Boş veri durumunda hata olarak işleme, normal durum olarak kabul et
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        // Gerçek hata durumu
        if (onError != null) {
          onError(e);
        } else {
          // Varsayılan hata mesajı
          errorMessage.value = 'Veriler yüklenirken bir hata oluştu';
          _logDebug('Veri yenileme sırasında hata: $e');
        }
      }
    } finally {
      // Yükleme durumunu her koşulda sıfırla (eğer isteniyorsa)
      if (resetLoadingState) {
        isLoading.value = false;
        _logDebug('Yükleme durumu sıfırlandı');
      }
    }
  }

  /// Yenileme işlemlerini önemli hata durumları için yönetir
  static Future<void> handleCriticalRefresh({
    required Future<void> Function() refreshAction,
    required RxBool isLoading,
    int maxRetries = 3,
    int retryDelay = 500,
  }) async {
    int retryCount = 0;
    bool success = false;

    while (!success && retryCount < maxRetries) {
      try {
        // Yeniden deneme gecikmesi (ilk deneme hariç)
        if (retryCount > 0) {
          await Future.delayed(Duration(milliseconds: retryDelay * retryCount));
        }

        // Asıl yenileme işlemi
        await refreshAction();
        success = true;
      } catch (e) {
        retryCount++;
        _logDebug(
            'Kritik yenileme hatası, yeniden deneme ${retryCount}/${maxRetries}: $e');

        // Son deneme başarısız olduysa
        if (retryCount >= maxRetries) {
          _logDebug('Maksimum yeniden deneme sayısına ulaşıldı');
          rethrow; // Hatayı yeniden fırlat
        }
      }
    }

    // Her durumda yükleme durumunu sıfırla
    isLoading.value = false;
  }

  /// Pull-to-refresh için standart işleyici
  static Future<void> handlePullToRefresh({
    required Future<void> Function() refreshAction,
    required RxBool isLoading,
    int timeoutMs = 5000,
  }) async {
    try {
      // Maksimum bekleme süresi ekle
      final refreshFuture = refreshAction();
      await refreshFuture.timeout(Duration(milliseconds: timeoutMs));
    } catch (e) {
      _logDebug('Pull-to-refresh sırasında hata: $e');
    } finally {
      // RefreshIndicator'ın düzgün kapanması için Future tamamla
      return Future.value();
    }
  }

  /// Token yenilemeden sonra güvenli yenileme işlemini gerçekleştirir
  static Future<void> safeRefreshAfterTokenRefresh({
    required Future<void> Function() refreshAction,
    required RxBool isLoading,
    int checkDelay = 800,
  }) async {
    // Token yenileme işlemlerinin tamamlanması için kısa bir süre bekle
    await Future.delayed(Duration(milliseconds: checkDelay));

    // Yükleme durumunu kontrol et
    if (isLoading.value) {
      _logDebug(
          'Token yenileme sonrası yükleme durumu hala aktif, sıfırlanıyor');
      isLoading.value = false;

      // Kısa bir gecikme daha ekle
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Normal yenileme işlemini gerçekleştir
    try {
      await refreshAction();
    } catch (e) {
      _logDebug('Token yenileme sonrası yenilemede hata: $e');
    }
  }

  /// Debug modunda log basar
  static void _logDebug(String message) {
    if (kDebugMode) {
      print('>>> PageRefreshService: $message');
    }
  }
}
