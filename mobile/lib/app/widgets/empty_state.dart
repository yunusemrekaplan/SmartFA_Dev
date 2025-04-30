import 'package:flutter/material.dart';

/// Liste veya sonuç olmadığında gösterilecek boş durum widget'ı.
/// İkon, başlık ve açıklama içerebilir.
class EmptyState extends StatelessWidget {
  /// Başlık metni
  final String title;

  /// Açıklama metni (opsiyonel)
  final String? subtitle;

  /// Gösterilecek ikon
  final IconData icon;

  /// İkon boyutu
  final double iconSize;

  /// İkon rengi (null ise tema rengini kullanır)
  final Color? iconColor;

  /// Eklenebilecek aksiyon butonu (opsiyonel)
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.iconSize = 80.0,
    this.iconColor,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Hesap, işlem veya bütçe olmaması durumlarında kullanılacak özel boş durum widget'ları
class NoAccountsEmptyState extends StatelessWidget {
  final VoidCallback? onAddPressed;

  const NoAccountsEmptyState({super.key, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Henüz Hesap Yok',
      subtitle: 'İlk finansal hesabınızı ekleyerek başlayın.',
      icon: Icons.account_balance_wallet_outlined,
      action: onAddPressed != null
          ? FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Hesap Ekle'),
            )
          : null,
    );
  }
}

class NoTransactionsEmptyState extends StatelessWidget {
  final VoidCallback? onAddPressed;

  const NoTransactionsEmptyState({super.key, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'İşlem Bulunamadı',
      subtitle: 'İlk işleminizi ekleyin veya filtreleri değiştirin.',
      icon: Icons.swap_horiz,
      action: onAddPressed != null
          ? FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('İşlem Ekle'),
            )
          : null,
    );
  }
}

class NoBudgetsEmptyState extends StatelessWidget {
  final VoidCallback? onAddPressed;

  const NoBudgetsEmptyState({super.key, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Henüz Bütçe Oluşturulmadı',
      subtitle: 'Harcamalarınızı takip etmek için bütçe oluşturun.',
      icon: Icons.account_balance_outlined,
      action: onAddPressed != null
          ? FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Bütçe Oluştur'),
            )
          : null,
    );
  }
}
