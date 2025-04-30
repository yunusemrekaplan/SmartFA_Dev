import 'package:flutter/material.dart';

/// Uygulama genelinde tutarlı bir yükleme göstergesi sağlar.
/// Farklı boyutlar ve yazı seçenekleri destekler.
class LoadingIndicator extends StatelessWidget {
  /// Gösterge etrafında görüntülenecek metin
  final String? message;

  /// Yükleme göstergesinin boyutu
  final double size;

  /// Gösterge kalınlığı
  final double strokeWidth;

  /// Arka plan rengi (overlay için)
  final Color? backgroundColor;

  /// Tam ekran overlay olarak gösterilsin mi?
  final bool isFullScreen;

  /// Metin stili
  final TextStyle? messageStyle;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 36.0,
    this.strokeWidth = 4.0,
    this.backgroundColor,
    this.isFullScreen = false,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final loadingWidget = _buildLoadingContent(context);

    if (isFullScreen) {
      return Container(
        color: backgroundColor ?? Colors.black.withOpacity(0.5),
        child: Center(
          child: loadingWidget,
        ),
      );
    }

    return loadingWidget;
  }

  Widget _buildLoadingContent(BuildContext context) {
    // Tema ve renklere erişim
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Metin varsa düzen farklı olacak
    if (message != null && message!.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message!,
            style: messageStyle ?? theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // Sadece gösterge
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
      ),
    );
  }
}

/// Tüm ekranı kaplayan bir yükleme göstergesi overlay'i oluşturur.
class FullScreenLoading extends StatelessWidget {
  final String? message;

  const FullScreenLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LoadingIndicator(
        message: message,
        isFullScreen: true,
      ),
    );
  }
}
