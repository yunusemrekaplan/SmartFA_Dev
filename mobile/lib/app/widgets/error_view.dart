import 'package:flutter/material.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/auth_exception.dart';
import 'package:mobile/app/data/network/exceptions/network_exception.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    super.key,
    this.error,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.retryText = 'Tekrar Dene',
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.isLarge = false,
    this.height,
  })  : assert(error != null || message != null, 'error veya message verilmelidir');

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
      message: message ?? 'İnternet bağlantısı sağlanamadı. Lütfen bağlantınızı kontrol edin.',
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

    return Center(
      child: Animate(
        effects: [
          FadeEffect(duration: 400.ms),
          SlideEffect(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          ),
        ],
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isLarge ? 350 : 300,
          ),
          padding: EdgeInsets.all(isLarge ? 24.0 : 16.0),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isLarge ? 64 : 48,
                height: isLarge ? 64 : 48,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.error,
                  size: isLarge ? 32 : 24,
                ),
              ),
              SizedBox(height: isLarge ? 16.0 : 12.0),
              Text(
                'Bir hata oluştu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isLarge ? 12.0 : 8.0),
              Text(
                displayMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                SizedBox(height: isLarge ? 24.0 : 16.0),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tekrar Dene'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    minimumSize: Size(isLarge ? 200 : 150, isLarge ? 48 : 40),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
