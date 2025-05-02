import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

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
  });

  /// Bilgilendirme tipinde bir panel oluşturur
  factory InfoPanel.info({
    required String title,
    required String message,
    VoidCallback? onActionPressed,
    String? actionText,
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
    );
  }

  /// Başarı tipinde bir panel oluşturur
  factory InfoPanel.success({
    required String title,
    required String message,
    VoidCallback? onActionPressed,
    String? actionText,
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
    );
  }

  /// Uyarı tipinde bir panel oluşturur
  factory InfoPanel.warning({
    required String title,
    required String message,
    VoidCallback? onActionPressed,
    String? actionText,
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
    );
  }

  /// Hata tipinde bir panel oluşturur
  factory InfoPanel.error({
    required String title,
    required String message,
    VoidCallback? onActionPressed,
    String? actionText,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.info,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor ?? AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: (textColor ?? AppColors.textPrimary)
                            .withOpacity(0.8),
                      ),
                ),
                if (onActionPressed != null && actionText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton(
                      onPressed: onActionPressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        backgroundColor:
                            (iconColor ?? AppColors.info).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        actionText!,
                        style: TextStyle(
                          color: iconColor ?? AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
