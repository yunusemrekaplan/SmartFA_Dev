import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Verilerin boş olduğu durumlar için görünüm
class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.actionText,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Animate(
        effects: [
          FadeEffect(duration: 400.ms),
          SlideEffect(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          ),
        ],
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 320,
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary.withOpacity(0.7),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: 24.0),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: actionIcon != null ? Icon(actionIcon) : const Icon(Icons.add_rounded),
                  label: Text(actionText!),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(220, 48),
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
