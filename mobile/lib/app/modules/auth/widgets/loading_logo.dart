import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Animasyonlu logo widget'ı
class LogoWithAnimation extends StatelessWidget {
  final double size;
  final bool animate;
  final Color backgroundColor;

  const LogoWithAnimation({
    super.key,
    this.size = 80,
    this.animate = true,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Container(
      padding: EdgeInsets.all(size * 0.2),
      decoration: BoxDecoration(
        color: backgroundColor == Colors.transparent
            ? AppColors.primary.withOpacity(0.1)
            : backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.account_balance_wallet,
        size: size * 0.75,
        color: AppColors.primary,
      ),
    );

    if (!animate) {
      return icon;
    }

    return icon
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(seconds: 2),
          color: AppColors.primary.withOpacity(0.2),
        )
        .scaleXY(
          begin: 1.0,
          end: 1.05,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        )
        .then()
        .scaleXY(
          begin: 1.05,
          end: 1.0,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
  }
}
