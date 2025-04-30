import 'package:flutter/material.dart';
import 'currency_text.dart';

/// Finansal hesap bilgilerini gösteren kart widget'ı.
class AccountCard extends StatelessWidget {
  /// Hesap adı
  final String accountName;

  /// Hesap bakiyesi
  final double balance;

  /// Para birimi
  final String currency;

  /// Hesap türü (banka, nakit, kredi kartı, vb.)
  final String accountType;

  /// Hesap türü ikonu
  final IconData? accountIcon;

  /// Kart tıklandığında çağrılacak fonksiyon
  final VoidCallback? onTap;

  /// Kart uzun basıldığında çağrılacak fonksiyon
  final VoidCallback? onLongPress;

  /// Kart içinde sağ tarafta gösterilecek ek butonlar
  final List<Widget>? actions;

  /// Kart arka plan rengi (null ise hesap türüne göre seçilir)
  final Color? backgroundColor;

  /// Kart gölge seviyesi
  final double elevation;

  /// Kart kenarlık yarıçapı
  final double borderRadius;

  const AccountCard({
    super.key,
    required this.accountName,
    required this.balance,
    required this.currency,
    required this.accountType,
    this.accountIcon,
    this.onTap,
    this.onLongPress,
    this.actions,
    this.backgroundColor,
    this.elevation = 2.0,
    this.borderRadius = 12.0,
  });

  /// Hesap türüne göre ikon belirle
  IconData _getAccountTypeIcon() {
    return accountIcon ?? _defaultIconForType(accountType);
  }

  /// Hesap türüne göre varsayılan ikon
  IconData _defaultIconForType(String type) {
    final String lowercaseType = type.toLowerCase();

    if (lowercaseType.contains('cash') || lowercaseType.contains('nakit')) {
      return Icons.money;
    } else if (lowercaseType.contains('credit') ||
        lowercaseType.contains('kredi')) {
      return Icons.credit_card;
    } else if (lowercaseType.contains('saving') ||
        lowercaseType.contains('birikim')) {
      return Icons.savings;
    } else if (lowercaseType.contains('investment') ||
        lowercaseType.contains('yatırım')) {
      return Icons.trending_up;
    } else {
      return Icons.account_balance; // Varsayılan banka hesabı
    }
  }

  /// Hesap türüne göre arka plan rengi belirle
  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) {
      return backgroundColor!;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final String lowercaseType = accountType.toLowerCase();

    // Farklı hesap türleri için farklı renkler
    if (lowercaseType.contains('cash') || lowercaseType.contains('nakit')) {
      return colorScheme.primaryContainer;
    } else if (lowercaseType.contains('credit') ||
        lowercaseType.contains('kredi')) {
      return colorScheme.errorContainer.withOpacity(0.7);
    } else if (lowercaseType.contains('saving') ||
        lowercaseType.contains('birikim')) {
      return colorScheme.secondaryContainer;
    } else if (lowercaseType.contains('investment') ||
        lowercaseType.contains('yatırım')) {
      return colorScheme.tertiaryContainer;
    } else {
      return colorScheme.surface; // Varsayılan yüzey rengi
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = _getBackgroundColor(context);
    final foregroundColor = theme.colorScheme.onSurface;

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hesap adı ve türü satırı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getAccountTypeIcon(),
                          color: foregroundColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            accountName,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (actions != null && actions!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    ...actions!,
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Hesap bakiyesi
              CurrencyText(
                amount: balance,
                currency: currency,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                colorizeNegative: true,
              ),

              const SizedBox(height: 4),

              // Hesap türü
              Text(
                accountType,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Birden çok hesabın toplamını gösteren özet kart
class AccountSummaryCard extends StatelessWidget {
  /// Toplam bakiye
  final double totalBalance;

  /// Para birimi
  final String currency;

  /// Hesap sayısı
  final int accountCount;

  /// Kart tıklandığında çağrılacak fonksiyon
  final VoidCallback? onTap;

  const AccountSummaryCard({
    super.key,
    required this.totalBalance,
    required this.currency,
    required this.accountCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Toplam Varlık',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CurrencyText(
                amount: totalBalance,
                currency: currency,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                colorizeNegative: true,
              ),
              const SizedBox(height: 4),
              Text(
                '$accountCount Aktif Hesap',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
