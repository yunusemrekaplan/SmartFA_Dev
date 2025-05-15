import 'package:flutter/material.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/error_handler/i_error_handler.dart';
import 'package:mobile/app/utils/snack_bar_button.dart';
import 'package:mobile/app/utils/snackbar_helper.dart';

/// Ağ hatalarını işleyen handler
class NetworkErrorHandler implements IErrorHandler {
  @override
  bool canHandle(AppException error) => error is NetworkException;

  @override
  void handle(
    AppException error,
    String message, {
    VoidCallback? onRetry,
    String? customTitle,
  }) {
    if (error is NetworkException) {
      final title = _getNetworkErrorTitle(error, customTitle);
      final icon = _getNetworkErrorIcon(error.code);

      // İnternet bağlantısı ile ilgili hatalar için yeniden deneme butonu ekleyelim
      if (error.code == 'CONNECTION_ERROR' || error.code == 'TIMEOUT_ERROR') {
        SnackbarHelper.showError(
          title: title,
          message: message,
          icon: icon,
          duration: const Duration(seconds: 5),
          mainButton: onRetry != null
              ? SnackBarButton(
                  label: 'Tekrar Dene',
                  onPressed: onRetry,
                  icon: Icons.refresh,
                )
              : null,
        );
      } else {
        SnackbarHelper.showError(
          title: title,
          message: message,
          icon: icon,
        );
      }
    }
  }

  /// Hata koduna göre başlık belirler
  String _getNetworkErrorTitle(NetworkException error, String? customTitle) {
    if (customTitle != null) return customTitle;

    if (error.statusCode != null) {
      if (error.statusCode! >= 500) {
        return 'Sunucu Hatası';
      } else if (error.statusCode == 404) {
        return 'Bulunamadı';
      } else if (error.statusCode == 403) {
        return 'Yetkisiz Erişim';
      } else if (error.statusCode == 429) {
        return 'Çok Fazla İstek';
      }
    }

    if (error.code == 'CONNECTION_ERROR') {
      return 'Bağlantı Hatası';
    } else if (error.code == 'TIMEOUT_ERROR') {
      return 'Zaman Aşımı';
    }

    return 'Ağ Hatası';
  }

  /// Hata koduna göre ikon belirler
  Icon _getNetworkErrorIcon(String? errorCode) {
    switch (errorCode) {
      case 'CONNECTION_ERROR':
        return const Icon(Icons.wifi_off, color: Colors.white);
      case 'TIMEOUT_ERROR':
        return const Icon(Icons.timer_off, color: Colors.white);
      case 'HTTP_404':
        return const Icon(Icons.find_in_page, color: Colors.white);
      case 'HTTP_403':
        return const Icon(Icons.no_encryption, color: Colors.white);
      case 'HTTP_429':
        return const Icon(Icons.hourglass_full, color: Colors.white);
      default:
        return const Icon(Icons.error_outline, color: Colors.white);
    }
  }
}
