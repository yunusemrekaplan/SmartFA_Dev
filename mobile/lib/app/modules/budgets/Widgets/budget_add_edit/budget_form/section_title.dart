import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Bölüm başlığı bileşeni - SRP (Single Responsibility) prensibi uygulandı
class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Duration animationDelay;

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.animationDelay = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 400),
          delay: animationDelay,
        );
  }
}
