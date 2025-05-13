import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

import 'budget_status_indicator.dart';

/// Bütçe kartının üst kısmında kategori bilgisini gösteren bileşen.
class BudgetCategoryHeader extends StatelessWidget {
  final String categoryName;
  final String? categoryIcon;
  final double spentPercentage;

  const BudgetCategoryHeader({
    super.key,
    required this.categoryName,
    this.categoryIcon,
    required this.spentPercentage,
  });

  @override
  Widget build(BuildContext context) {
    // İlerleme çubuğu ve vurgular için durum rengi
    Color statusColor;
    if (spentPercentage >= 1.0) {
      statusColor = AppColors.error; // Bütçeyi aşmış
    } else if (spentPercentage >= 0.85) {
      statusColor = AppColors.warning; // Bütçe limitine yaklaşıyor
    } else {
      statusColor = AppColors.success; // Normal harcama
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori ikonu
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: categoryIcon != null && categoryIcon!.isNotEmpty
              ? Icon(
                  IconData(int.parse(categoryIcon!), fontFamily: 'MaterialIcons'),
                  color: statusColor,
                  size: 24,
                )
              : Icon(
                  Icons.category_outlined,
                  color: statusColor,
                  size: 24,
                ),
        ),

        const SizedBox(width: 16),

        // Kategori adı ve durum etiketi
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              BudgetStatusIndicator(spentPercentage: spentPercentage),
            ],
          ),
        ),
      ],
    );
  }
}
