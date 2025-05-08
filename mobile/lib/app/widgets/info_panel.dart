import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Bilgi paneli - dashboard'da farklı bilgiler göstermek için kullanılabilir
class InfoPanel extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final bool isDismissible;
  final VoidCallback? onDismiss;

  const InfoPanel({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.onActionPressed,
    this.actionText,
    this.isDismissible = false,
    this.onDismiss,
  });

  /// Bilgilendirme tipinde bir panel oluşturur
  factory InfoPanel.info({
    required String title,
    required String message,
    VoidCallback? onActionPressed,
    String? actionText,
    bool isDismissible = false,
    VoidCallback? onDismiss,
  }) {
    return InfoPanel(
      title: title,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: AppColors.info.withOpacity(0.1),
      iconColor: AppColors.info,
      textColor: AppColors.textPrimary,
      onActionPressed: onActionPressed,
      actionText: actionText,
      isDismissible: isDismissible,
      onDismiss: onDismiss,
    );
  }

  /// Başarı tipinde bir panel oluşturur
  factory InfoPanel.success({
    required String title,
    required String message,
    VoidCallback? onActionPressed,
    String? actionText,
    bool isDismissible = false,
    VoidCallback? onDismiss,
  }) {
    return InfoPanel(
      title: title,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: AppColors.success.withOpacity(0.1),
      iconColor: AppColors.success,
      textColor: AppColors.textPrimary,
      onActionPressed: onActionPressed,
      actionText: actionText,
      isDismissible: isDismissible,
      onDismiss: onDismiss,
    );
  }

  /// Uyarı tipinde bir panel oluşturur
  factory InfoPanel.warning({
    required String title,
    required String message,
    VoidCallback? onActionPressed,
    String? actionText,
    bool isDismissible = false,
    VoidCallback? onDismiss,
  }) {
    return InfoPanel(
      title: title,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: AppColors.warning.withOpacity(0.1),
      iconColor: AppColors.warning,
      textColor: AppColors.textPrimary,
      onActionPressed: onActionPressed,
      actionText: actionText,
      isDismissible: isDismissible,
      onDismiss: onDismiss,
    );
  }

  /// Hata tipinde bir panel oluşturur
  factory InfoPanel.error({
    required String title,
    required String message,
    VoidCallback? onActionPressed,
    String? actionText,
    bool isDismissible = false,
    VoidCallback? onDismiss,
  }) {
    return InfoPanel(
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: AppColors.error.withOpacity(0.1),
      iconColor: AppColors.error,
      textColor: AppColors.textPrimary,
      onActionPressed: onActionPressed,
      actionText: actionText,
      isDismissible: isDismissible,
      onDismiss: onDismiss,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget panel = Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        border: Border.all(
          color: (iconColor ?? AppColors.info).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // İkon Bölümü
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (iconColor ?? AppColors.info).withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.info,
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // İçerik Bölümü
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve Kapat Butonu (varsa)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColor ?? AppColors.textPrimary,
                                  ),
                        ),
                      ),
                      if (isDismissible && onDismiss != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: onDismiss,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          tooltip: 'Kapat',
                          color: (textColor ?? AppColors.textPrimary)
                              .withOpacity(0.5),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Mesaj
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: (textColor ?? AppColors.textPrimary)
                              .withOpacity(0.8),
                          height: 1.4,
                        ),
                  ),

                  // Aksiyon Butonu (varsa)
                  if (onActionPressed != null && actionText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: OutlinedButton(
                        onPressed: onActionPressed,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          side: BorderSide(
                            color: iconColor ?? AppColors.info,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.kBorderRadius),
                          ),
                          minimumSize: const Size(10, 36),
                          foregroundColor: iconColor ?? AppColors.info,
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          actionText!,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: iconColor ?? AppColors.info,
                                    fontSize: 14,
                                  ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
        begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);

    // Kaydırarak kapatma özelliği
    if (isDismissible && onDismiss != null) {
      return Dismissible(
        key: Key('info_panel_${title.hashCode}'),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => onDismiss!(),
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.error,
          ),
        ),
        child: panel,
      );
    }

    return panel;
  }
}
