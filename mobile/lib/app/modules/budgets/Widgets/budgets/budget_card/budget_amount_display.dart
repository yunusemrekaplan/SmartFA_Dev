import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Bütçe miktarlarını (harcanan, toplam ve kalan) gösteren bileşen.
class BudgetAmountDisplay extends StatelessWidget {
  final double amount;
  final double spentAmount;
  final NumberFormat currencyFormatter;
  final Color statusColor;

  const BudgetAmountDisplay({
    super.key,
    required this.amount,
    required this.spentAmount,
    required this.currencyFormatter,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final double remainingAmount = amount - spentAmount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Harcanan / Toplam
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Harcanan / Toplam',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                  children: [
                    TextSpan(
                      text: currencyFormatter.format(spentAmount),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ' / '),
                    TextSpan(
                      text: currencyFormatter.format(amount),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Kalan
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Kalan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormatter.format(remainingAmount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: remainingAmount >= 0 ? statusColor : AppColors.error,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
