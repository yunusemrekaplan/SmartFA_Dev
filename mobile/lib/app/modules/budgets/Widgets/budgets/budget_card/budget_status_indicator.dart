import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Budget durumunu (Normal, Limit Yakın, Bütçe Aşımı) gösteren etiket bileşeni.
class BudgetStatusIndicator extends StatelessWidget {
  final double spentPercentage;

  const BudgetStatusIndicator({
    super.key,
    required this.spentPercentage,
  });

  @override
  Widget build(BuildContext context) {
    // İlerleme çubuğu ve vurgular için durum rengi
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (spentPercentage >= 1.0) {
      statusColor = AppColors.error; // Bütçeyi aşmış
      statusIcon = Icons.error_outline_rounded;
      statusText = 'Bütçe Aşımı';
    } else if (spentPercentage >= 0.85) {
      statusColor = AppColors.warning; // Bütçe limitine yaklaşıyor
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'Limit Yakın';
    } else {
      statusColor = AppColors.success; // Normal harcama
      statusIcon = Icons.check_circle_outline_rounded;
      statusText = 'Normal';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 12,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
