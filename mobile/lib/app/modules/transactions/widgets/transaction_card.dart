import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Tek bir işlem kartını gösteren gelişmiş Widget
class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final NumberFormat currencyFormatter;
  final IconData Function(String?) getCategoryIcon;
  final TransactionsController controller;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.currencyFormatter,
    required this.getCategoryIcon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // İşlem tipine göre renkler ve ikonlar
    final bool isIncome = transaction.categoryType == CategoryType.Income;
    final Color typeColor = isIncome ? AppColors.income : AppColors.expense;
    final IconData typeIcon =
        isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final IconData categoryIcon = getCategoryIcon(transaction.categoryIcon);

    // Tarih formatlayıcı
    final dateFormatter = DateFormat('d MMM, EEE', 'tr_TR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: AppTheme.kCardElevation,
      shadowColor: AppColors.shadowLight,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
        onTap: () => controller.goToEditTransaction(transaction),
        splashColor: typeColor.withOpacity(0.1),
        highlightColor: typeColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Kategori İkonu
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: typeColor,
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: typeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      typeIcon,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // İşlem Detayları
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      transaction.categoryName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            transaction.accountName,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildDot(),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          // Daha kısa tarih formatı
                          DateFormat('d MMM', 'tr_TR')
                              .format(transaction.transactionDate),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    if (transaction.notes != null &&
                        transaction.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          transaction.notes!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                    fontStyle: FontStyle.italic,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Tutar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isIncome
                      ? currencyFormatter.format(transaction.amount)
                      : '-${currencyFormatter.format(transaction.amount)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 50.ms).slideX(
        begin: 0.1,
        end: 0,
        duration: 300.ms,
        delay: 50.ms,
        curve: Curves.easeOutCubic);
  }

  /// Ayırıcı nokta widget'ı
  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textTertiary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
