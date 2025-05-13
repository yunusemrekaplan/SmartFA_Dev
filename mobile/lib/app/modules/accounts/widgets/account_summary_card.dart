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
      shadowColor: iconColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: iconColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor.withOpacity(0.4),
              backgroundColor.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İkon ve başlık
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
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
                    border: Border.all(
                      color: iconColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tutar
            Row(
              children: [
                Expanded(
                  child: Text(
                    isNegative
                        ? '- ${currencyFormatter.format(amount)}'
                        : currencyFormatter.format(amount),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: isNegative ? iconColor : null,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Icon(
                  isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                  color: iconColor,
                  size: 18,
                ),
              ],
            ),

            // Açıklama
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                isNegative ? 'Toplam borç miktarı' : 'Toplam varlık miktarı',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
