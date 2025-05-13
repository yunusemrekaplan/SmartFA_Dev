import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Bütçe ilerleme çubuğunu gösteren widget.
class BudgetProgressBar extends StatelessWidget {
  final double spentPercentage;
  final Color statusColor;

  const BudgetProgressBar({
    super.key,
    required this.spentPercentage,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      child: Stack(
        children: [
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            height: 14,
            width: MediaQuery.of(context).size.width * 0.9 * spentPercentage.clamp(0.0, 1.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(8),
                bottomLeft: const Radius.circular(8),
                topRight: spentPercentage >= 1.0 ? const Radius.circular(8) : Radius.zero,
                bottomRight: spentPercentage >= 1.0 ? const Radius.circular(8) : Radius.zero,
              ),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  statusColor.withOpacity(0.7),
                  statusColor,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
