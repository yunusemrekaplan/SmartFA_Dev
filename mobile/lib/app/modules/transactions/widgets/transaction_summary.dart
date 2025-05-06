import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// İşlem özeti kartını gösteren Widget
class TransactionSummary extends StatelessWidget {
  final TransactionsController controller;
  final NumberFormat currencyFormatter;

  const TransactionSummary({
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

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            // Gelir/Gider özeti
            Row(
              children: [
                _buildSummaryItem(
                  title: 'Gelir',
                  amount: controller.totalIncome.value,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.success,
                  flex: 1,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                _buildSummaryItem(
                  title: 'Gider',
                  amount: controller.totalExpense.value,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.error,
                  flex: 1,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dönem seçici
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.selectedStartDate.value == null
                        ? 'Tüm Zamanlar'
                        : "${DateFormat('dd MMM', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('dd MMM', 'tr_TR').format(controller.selectedEndDate.value!)}",
                    style: Get.theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Özet bilgisi oluşturur
  Widget _buildSummaryItem({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Get.theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                currencyFormatter.format(amount),
                style: Get.theme.textTheme.titleLarge?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
