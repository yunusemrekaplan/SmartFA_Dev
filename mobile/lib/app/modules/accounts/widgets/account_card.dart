import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/account_type.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Tek bir hesabı gösteren modern kart widget'ı
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
      decimalDigits: 2,
    );

    final (IconData accountIcon, Color accountColor) =
        _getAccountTypeInfo(account.type);
    final Color balanceColor =
        account.currentBalance >= 0 ? AppColors.success : AppColors.error;

    // Arka plan rengi
    final Color cardBackgroundColor = Colors.white;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                account.currentBalance >= 0
                    ? accountColor.withOpacity(0.05)
                    : AppColors.error.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Hesap ikonu - daha modern tasarım
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accountColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accountColor.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accountColor.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    accountIcon,
                    color: accountColor,
                    size: 24,
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accountColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getAccountTypeName(account.type),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accountColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            account.currentBalance >= 0
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color: balanceColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currencyFormatter.format(account.currentBalance),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: balanceColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // İşlem menüsü
                _buildActionMenu(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// İşlem menüsünü oluşturur
  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      icon: Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
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

  /// Hesap türünün adını döndürür
  String _getAccountTypeName(AccountType accountType) {
    switch (accountType) {
      case AccountType.Cash:
        return 'Nakit';
      case AccountType.Bank:
        return 'Banka';
      case AccountType.CreditCard:
        return 'Kredi Kartı';
    }
  }
}
