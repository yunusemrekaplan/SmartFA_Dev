import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// İşlem özeti kartını gösteren gelişmiş Widget
class TransactionSummary extends StatelessWidget {
  final TransactionsController controller;
  final NumberFormat currencyFormatter;
  final GlobalKey _dateButtonKey = GlobalKey();

  TransactionSummary({
    super.key,
    required this.controller,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Yükleme durumunda özet gösterme
      if (controller.isLoading.value && controller.transactionList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Card(
        //margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        elevation: AppTheme.kCardElevation,
        shadowColor: AppColors.shadowLight,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColors.primary.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Dönem seçici - Merkeze yerleştirildi
                Center(
                  child: InkWell(
                    key: _dateButtonKey,
                    onTap: () {
                      // Butonun pozisyonunu al
                      final RenderBox? renderBox = _dateButtonKey.currentContext
                          ?.findRenderObject() as RenderBox?;
                      if (renderBox == null) return;

                      final Offset offset =
                          renderBox.localToGlobal(Offset.zero);

                      // Popup menüyü göster
                      controller.showQuickDateMenu(
                          context, Offset(offset.dx, offset.dy));
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getDateRangeText(context),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(
                      begin: -0.2,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 28),

                // Gelir/Gider özeti - Daha büyük ve görsel
                Row(
                  children: [
                    _buildSummaryItem(
                      context: context,
                      title: 'Gelir',
                      amount: controller.totalIncome.value,
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.income,
                      iconBackgroundColor: AppColors.income.withOpacity(0.1),
                      flex: 1,
                      index: 0,
                    ),
                    Container(
                      height: 80,
                      width: 1,
                      color: AppColors.divider,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    _buildSummaryItem(
                      context: context,
                      title: 'Gider',
                      amount: controller.totalExpense.value,
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.expense,
                      iconBackgroundColor: AppColors.expense.withOpacity(0.1),
                      flex: 1,
                      index: 1,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Denge (Gelir-Gider farkı)
                _buildBalanceItem(context),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          );
    });
  }

  /// Özet bilgisi oluşturur
  Widget _buildSummaryItem({
    required BuildContext context,
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required Color iconBackgroundColor,
    required int flex,
    required int index,
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  currencyFormatter.format(amount),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
          .slideY(
            begin: 0.2,
            end: 0,
            duration: 500.ms,
            delay: Duration(milliseconds: 100 * index),
            curve: Curves.easeOutCubic,
          ),
    );
  }

  /// Bakiye bilgisi oluşturur
  Widget _buildBalanceItem(BuildContext context) {
    final double balance =
        controller.totalIncome.value - controller.totalExpense.value;
    final bool isPositive = balance >= 0;
    final Color balanceColor =
        isPositive ? AppColors.income : AppColors.expense;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: balanceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: balanceColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: balanceColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Net Durum',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPositive ? '+' : '',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: balanceColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Flexible(
                child: Text(
                  currencyFormatter.format(balance.abs()),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: balanceColor,
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 500.ms,
          delay: 200.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Tarih aralığı metnini oluşturur
  String _getDateRangeText(BuildContext context) {
    // Eğer hızlı tarih filtresi aktifse, onun adını göster
    if (controller.selectedQuickDate.value != null) {
      switch (controller.selectedQuickDate.value) {
        case 'today':
          return 'Bugün';
        case 'yesterday':
          return 'Dün';
        case 'thisWeek':
          return 'Bu Hafta';
        case 'thisMonth':
          return 'Bu Ay';
        case 'lastMonth':
          return 'Geçen Ay';
        case 'last3Months':
          return 'Son 3 Ay';
        case 'lastYear':
          return 'Son 1 Yıl';
        case 'all':
          return 'Tüm Zamanlar';
      }
    }

    // Özel tarih aralığı seçilmişse tarih aralığını göster
    if (controller.selectedStartDate.value != null) {
      return "${DateFormat('dd MMM', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('dd MMM', 'tr_TR').format(controller.selectedEndDate.value!)}";
    }

    // Tarih seçilmemişse
    return 'Tüm Zamanlar';
  }
}
