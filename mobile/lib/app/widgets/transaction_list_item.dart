import 'package:flutter/material.dart';
import 'currency_text.dart';

/// İşlem listelerinde kullanılacak öğe widget'ı.
class TransactionListItem extends StatelessWidget {
  /// İşlem başlığı
  final String title;

  /// İşlem kategorisi
  final String category;

  /// İşlem tutarı
  final double amount;

  /// Para birimi
  final String currency;

  /// İşlem tarihi
  final DateTime date;

  /// İşlem için gösterilecek ikon
  final IconData? icon;

  /// İşlem kategorisi için renk
  final Color? categoryColor;

  /// Öğe tıklandığında çağrılacak fonksiyon
  final VoidCallback? onTap;

  /// Uzun basıldığında çağrılacak fonksiyon
  final VoidCallback? onLongPress;

  /// Sağda gösterilecek aksiyonlar
  final List<Widget>? actions;

  /// Gelir/gider gösterimini etkileyen işlem türü
  final TransactionType type;

  const TransactionListItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    required this.type,
    this.icon,
    this.categoryColor,
    this.onTap,
    this.onLongPress,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Kategori ikonu
            _buildCategoryIcon(theme),
            const SizedBox(width: 16),

            // Başlık ve kategori
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        category,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.circle,
                        size: 5,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(date),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tutar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CurrencyText(
                  amount: _getAmountWithSign(),
                  currency: currency,
                  colorizeNegative: true,
                  style: theme.textTheme.titleMedium,
                ),
                if (actions != null && actions!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Kategori ikonu widget'ı
  Widget _buildCategoryIcon(ThemeData theme) {
    final color = categoryColor ?? theme.colorScheme.primary;
    final iconData = icon ?? _getDefaultIcon();

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 20,
      ),
    );
  }

  /// İşlem türüne göre varsayılan ikon
  IconData _getDefaultIcon() {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      default:
        return Icons.monetization_on;
    }
  }

  /// İşlem tarihini formatlar
  String _formatDate(DateTime date) {
    // Basit tarih formatı, isterseniz intl paketini kullanarak daha karmaşık formatlar oluşturabilirsiniz
    return '${date.day}/${date.month}/${date.year}';
  }

  /// İşlem türüne göre tutarın işaretini belirler
  double _getAmountWithSign() {
    switch (type) {
      case TransactionType.income:
        return amount.abs(); // Gelir pozitif
      case TransactionType.expense:
        return -amount.abs(); // Gider negatif
      case TransactionType.transfer:
        return amount; // Transfer işareti korunur
      default:
        return amount;
    }
  }
}

/// İşlem gruplarını ayıran başlık widget'ı
class TransactionGroupHeader extends StatelessWidget {
  /// Grup başlığı (ör. "Bugün", "Dün", "Ocak 2023")
  final String title;

  /// Bu gruptaki toplam işlem tutarı (opsiyonel)
  final double? totalAmount;

  /// Para birimi (totalAmount verilmişse gerekli)
  final String? currency;

  const TransactionGroupHeader({
    super.key,
    required this.title,
    this.totalAmount,
    this.currency,
  }) : assert(
            (totalAmount == null && currency == null) ||
                (totalAmount != null && currency != null),
            'Para birimi ve tutar birlikte belirtilmelidir');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (totalAmount != null && currency != null)
            CurrencyText(
              amount: totalAmount!,
              currency: currency!,
              colorizeNegative: true,
              style: theme.textTheme.titleSmall,
            ),
        ],
      ),
    );
  }
}

/// İşlem türleri enum
enum TransactionType {
  income, // Gelir
  expense, // Gider
  transfer, // Transfer
}
