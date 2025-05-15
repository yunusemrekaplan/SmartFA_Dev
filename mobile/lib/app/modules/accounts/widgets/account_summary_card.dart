import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Varlık ve borç özetleri için modern kart widget'ı
class AccountSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isNegative;

  const AccountSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    // Para formatlayıcı
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shadowColor: iconColor.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: iconColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İkon ve başlık
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tutar
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    isNegative
                        ? '- ${currencyFormatter.format(amount)}'
                        : currencyFormatter.format(amount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isNegative ? iconColor : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),

            // Açıklama
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                isNegative ? 'Toplam borç' : 'Toplam varlık',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
