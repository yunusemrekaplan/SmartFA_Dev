import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Son işlemler için modern kart tasarımı
class TransactionSummaryCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final bool isDetailed;

  const TransactionSummaryCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.isDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    // Para birimi formatlayıcı
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    // Tarih formatlayıcı
    final dateFormatter = DateFormat('d MMM', 'tr_TR');

    // İşlem türüne göre renk ve simge belirle
    final bool isIncome = transaction.categoryType == CategoryType.Income;
    final Color typeColor = isIncome ? AppColors.income : AppColors.expense;
    final IconData typeIcon =
        isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    // Kategori simgesi
    final IconData categoryIcon = _getCategoryIcon(transaction.categoryIcon);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      elevation: AppTheme.kCardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
      ),
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
        splashColor: typeColor.withOpacity(0.1),
        highlightColor: typeColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // Kategori simgesi
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

              // İşlem bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.accountName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        _buildDot(),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatter.format(transaction.transactionDate),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    // Not kısmı (opsiyonel)
                    if (isDetailed &&
                        transaction.notes != null &&
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

              // İşlem tutarı
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isIncome
                      ? currencyFormatter.format(transaction.amount)
                      : '- ${currencyFormatter.format(transaction.amount)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  /// Kategori icon string'inden IconData oluşturur
  IconData _getCategoryIcon(String? iconString) {
    // Boş ya da hatalı olma durumunu kontrol et
    if (iconString == null || iconString.isEmpty) {
      return Icons.category; // Varsayılan icon
    }

    try {
      return IconData(
        int.parse(iconString),
        fontFamily: 'MaterialIcons',
      );
    } catch (e) {
      // Parse hatası durumunda varsayılan
      return Icons.category;
    }
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

/// Hızlı işlem ekleme bileşeni
class QuickTransactionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final CategoryType type;
  final VoidCallback onTap;

  const QuickTransactionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = type == CategoryType.Income;
    final Color typeColor = isIncome ? AppColors.income : AppColors.expense;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: typeColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1, 1),
        duration: 300.ms);
  }
}
