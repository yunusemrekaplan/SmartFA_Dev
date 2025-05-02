import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/account_type.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Tek bir hesabı gösteren minimal kart widget'ı
class AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
    );

    final (IconData accountIcon, Color accountColor) =
        _getAccountTypeInfo(account.type);
    final Color balanceColor =
        account.currentBalance >= 0 ? accountColor : AppColors.error;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Hesap ikonu
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  accountIcon,
                  color: accountColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Hesap bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(account.currentBalance),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: balanceColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),

              // İşlem menüsü
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onTap();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text('Düzenle'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        const Text('Sil'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hesap türüne göre ikon ve renk bilgilerini döndürür
  (IconData, Color) _getAccountTypeInfo(AccountType accountType) {
    switch (accountType) {
      case AccountType.Cash:
        return (Icons.wallet_outlined, AppColors.success);
      case AccountType.Bank:
        return (Icons.account_balance_outlined, AppColors.primary);
      case AccountType.CreditCard:
        return (Icons.credit_card_outlined, AppColors.secondary);
    }
  }
}
