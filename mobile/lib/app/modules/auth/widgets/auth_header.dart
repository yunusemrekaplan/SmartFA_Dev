import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/modules/auth/widgets/loading_logo.dart';

/// Auth ekranlarının üst kısmında yer alan logo ve başlık bileşeni
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double logoSize;
  final bool animateLogo;
  final Color logoBackgroundColor;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoSize = 80,
    this.animateLogo = true,
    this.logoBackgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          LogoWithAnimation(
            size: logoSize,
            animate: animateLogo,
            backgroundColor: logoBackgroundColor,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
