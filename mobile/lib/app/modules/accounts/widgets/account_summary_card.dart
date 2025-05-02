import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Varlık ve borç özetleri için kart widget'ı
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
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: iconColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tutar
            Text(
              isNegative
                  ? '- ${currencyFormatter.format(amount)}'
                  : currencyFormatter.format(amount),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isNegative ? iconColor : null,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // Açıklama
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                isNegative ? 'Toplam borç miktarı' : 'Toplam varlık miktarı',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
