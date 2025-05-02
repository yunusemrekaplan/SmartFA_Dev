import 'package:flutter/material.dart';
import 'package:mobile/app/utils/exceptions.dart';

/// Hata durumlarını görüntülemek için kullanılan widget.
/// Farklı hata türleri için özelleştirilmiş görünümler sunar.
class ErrorView extends StatelessWidget {
  /// Gösterilecek hata nesnesi
  final AppException? error;

  /// Hata mesajı (error null ise kullanılır)
  final String? message;

  /// Yeniden deneme fonksiyonu (null ise yeniden deneme butonu gösterilmez)
  final VoidCallback? onRetry;

  /// Hata icon'u
  final IconData icon;

  /// Ana buton metni (default: "Tekrar Dene")
  final String retryText;

  /// İkinci buton metni ve işlevi
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;

  /// Hata büyük mü görüntülensin?
  final bool isLarge;

  /// Widget yüksekliği
  final double? height;

  const ErrorView({
    Key? key,
    this.error,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.retryText = 'Tekrar Dene',
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.isLarge = true,
    this.height,
  })  : assert(error != null || message != null,
            'error veya message verilmelidir'),
        super(key: key);

  /// Özel network hatası görünümü
  factory ErrorView.network({
    Key? key,
    NetworkException? error,
    String? message,
    VoidCallback? onRetry,
    bool isLarge = true,
    double? height,
  }) {
    return ErrorView(
      key: key,
      error: error,
      message: message ??
          'İnternet bağlantısı sağlanamadı. Lütfen bağlantınızı kontrol edin.',
      onRetry: onRetry,
      icon: Icons.wifi_off_rounded,
      isLarge: isLarge,
      height: height,
      retryText: 'Yeniden Bağlan',
    );
  }

  /// Veri bulunamadı görünümü
  factory ErrorView.noData({
    Key? key,
    String? message,
    VoidCallback? onRetry,
    VoidCallback? onAdd,
    bool isLarge = true,
    double? height,
  }) {
    return ErrorView(
      key: key,
      message: message ?? 'Gösterilecek veri bulunamadı.',
      onRetry: onRetry,
      icon: Icons.inbox_outlined,
      isLarge: isLarge,
      height: height,
      retryText: 'Yenile',
      secondaryButtonText: onAdd != null ? 'Yeni Ekle' : null,
      onSecondaryButtonPressed: onAdd,
    );
  }

  /// Yetkilendirme hatası görünümü
  factory ErrorView.auth({
    Key? key,
    AuthException? error,
    String? message,
    VoidCallback? onLogin,
    bool isLarge = true,
    double? height,
  }) {
    return ErrorView(
      key: key,
      error: error,
      message: message ?? 'Oturum süresi doldu veya yetki hatası oluştu.',
      onRetry: onLogin,
      icon: Icons.lock_outline_rounded,
      isLarge: isLarge,
      height: height,
      retryText: 'Giriş Yap',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gösterilecek mesajı belirle
    final displayMessage = message ?? error?.message ?? 'Bir hata oluştu.';

    if (isLarge) {
      return _buildLargeErrorView(context, displayMessage);
    } else {
      return _buildCompactErrorView(context, displayMessage);
    }
  }

  /// Tam ekran hata görünümü
  Widget _buildLargeErrorView(BuildContext context, String displayMessage) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: _getIconColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            if (onRetry != null) ...[
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(retryText),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (secondaryButtonText != null &&
                onSecondaryButtonPressed != null) ...[
              TextButton(
                onPressed: onSecondaryButtonPressed,
                child: Text(secondaryButtonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Kompakt hata görünümü (Liste itemı veya küçük kart için)
  Widget _buildCompactErrorView(BuildContext context, String displayMessage) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: _getIconColor(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              tooltip: retryText,
            ),
          ],
        ],
      ),
    );
  }

  /// Hata tipine göre uygun icon rengini döndürür
  Color _getIconColor(BuildContext context) {
    if (error is AuthException) {
      return Colors.orange;
    } else if (error is NetworkException) {
      return Colors.blue;
    } else if (error is ValidationException) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}
