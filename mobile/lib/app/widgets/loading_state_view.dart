import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Yükleme durumları için daha gelişmiş görünüm
class LoadingStateView extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const LoadingStateView({
    super.key,
    this.message,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 24),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: content.animate().fade(duration: 400.ms),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: content.animate().fade(duration: 400.ms),
      ),
    );
  }
}
