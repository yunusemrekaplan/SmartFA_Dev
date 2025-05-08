import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Aktif filtreleri gösteren gelişmiş chip'leri içeren satır Widget'ı
class ActiveFiltersRow extends StatelessWidget {
  final TransactionsController controller;

  const ActiveFiltersRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Widget> chips = [];

      // Hesap filtresi
      if (controller.selectedAccount.value != null) {
        chips.add(_buildFilterChip(
          context: context,
          label: controller.selectedAccount.value!.name,
          onDeleted: () => controller.selectAccountFilter(null),
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.primary,
          index: chips.length,
        ));
      }

      // Kategori filtresi
      if (controller.selectedCategory.value != null) {
        // Kategori tipine göre renk belirle
        final Color categoryColor =
            controller.selectedCategory.value!.type == CategoryType.Income
                ? AppColors.income
                : AppColors.expense;

        chips.add(_buildFilterChip(
          context: context,
          label: controller.selectedCategory.value!.name,
          onDeleted: () => controller.selectCategoryFilter(null),
          icon: Icons.category_outlined,
          color: categoryColor,
          index: chips.length,
        ));
      }

      // İşlem tipi filtresi
      if (controller.selectedType.value != null) {
        final bool isExpense =
            controller.selectedType.value == CategoryType.Expense;
        chips.add(_buildFilterChip(
          context: context,
          label: isExpense ? 'Gider' : 'Gelir',
          onDeleted: () => controller.selectTypeFilter(null),
          icon: isExpense
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded,
          color: isExpense ? AppColors.expense : AppColors.income,
          index: chips.length,
        ));
      }

      // Tarih filtresi
      if (controller.selectedStartDate.value != null) {
        chips.add(_buildFilterChip(
          context: context,
          label:
              '${DateFormat('d MMM', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('d MMM', 'tr_TR').format(controller.selectedEndDate.value!)}',
          onDeleted: () {
            controller.selectedStartDate.value = null;
            controller.selectedEndDate.value = null;
            controller.applyFilters();
          },
          icon: Icons.date_range_rounded,
          color: AppColors.info,
          index: chips.length,
        ));
      }

      // Hızlı tarih filtresi
      if (controller.selectedQuickDate.value != null) {
        String periodText = '';
        switch (controller.selectedQuickDate.value) {
          case 'today':
            periodText = 'Bugün';
            break;
          case 'yesterday':
            periodText = 'Dün';
            break;
          case 'thisWeek':
            periodText = 'Bu Hafta';
            break;
          case 'thisMonth':
            periodText = 'Bu Ay';
            break;
          case 'lastMonth':
            periodText = 'Geçen Ay';
            break;
          case 'last3Months':
            periodText = 'Son 3 Ay';
            break;
        }

        if (periodText.isNotEmpty) {
          chips.add(_buildFilterChip(
            context: context,
            label: periodText,
            onDeleted: () {
              controller.selectedQuickDate.value = null;
              controller.applyFilters();
            },
            icon: Icons.access_time_rounded,
            color: AppColors.info,
            index: chips.length,
          ));
        }
      }

      if (chips.isEmpty) {
        return const SizedBox.shrink();
      }

      // Filtre temizleme butonu
      if (chips.isNotEmpty) {
        chips.add(
          InkWell(
            onTap: controller.clearFilters,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Temizle',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 200.ms),
        );
      }

      // Kaydırılabilir filtre chip'leri
      return Container(
        height: 56,
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 8),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: chips.length,
          itemBuilder: (context, index) => chips[index],
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      );
    });
  }

  /// Gelişmiş tasarlanmış filtre chip'i
  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required VoidCallback onDeleted,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    return Chip(
      avatar: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14,
          color: color,
        ),
      ),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
      ),
      deleteIcon: Container(
        margin: const EdgeInsets.only(left: 0),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 14,
        ),
      ),
      onDeleted: onDeleted,
      deleteIconColor: AppColors.textSecondary,
      backgroundColor: Colors.white,
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: 50 * index),
        )
        .slideX(
          begin: 0.2,
          end: 0.0,
          duration: 300.ms,
          delay: Duration(milliseconds: 50 * index),
          curve: Curves.easeOutCubic,
        );
  }
}
