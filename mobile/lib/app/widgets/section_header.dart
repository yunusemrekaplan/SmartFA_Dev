import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Dashboard ekranındaki bölüm başlıkları için özelleştirilmiş widget
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final IconData? actionIcon;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onActionPressed,
    this.actionText,
    this.actionIcon,
    this.padding = const EdgeInsets.only(bottom: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Başlık ve alt başlık
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13, // bodyMedium 14, 13'e çekiyoruz
                            // color: AppColors.textSecondary, // Zaten bodyMedium rengi
                          ),
                    ),
                  ),
              ],
            ),
          ),

          // Aksiyon butonu
          if (onActionPressed != null)
            TextButton(
              onPressed: onActionPressed,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      // fontSize: 14, // bodyMedium zaten 14
                      fontWeight: FontWeight.w600,
                    ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText ?? 'Tümünü Gör',
                    style: Theme.of(context)
                        .textButtonTheme
                        .style
                        ?.textStyle
                        ?.resolve({}) // Resolve for default state
                        ?.copyWith(
                      fontWeight: FontWeight
                          .w600, // TextButton temasından alıp bold yapıyoruz
                    ),
                  ),
                  if (actionIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        actionIcon ?? Icons.arrow_forward_rounded,
                        size: 16,
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
