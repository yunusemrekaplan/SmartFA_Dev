import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/filter_bottom_sheet.dart';

/// Aktif filtreleri gösteren bar widget'ı - Bütçe ekranındaki tasarıma benzer şekilde
class ActiveFiltersRow extends StatelessWidget {
  final TransactionsController controller;

  const ActiveFiltersRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasFilters = controller.hasActiveFilters;

      if (!hasFilters) return const SizedBox.shrink();

      // Aktif filtreleri gösteren bar
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppColors.surfaceVariant,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildFilterChips(context),
                ),
              ),
            ),

            // Tüm filtreleri temizle butonu
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: controller.clearFilters,
              tooltip: 'Filtreleri Temizle',
              visualDensity: VisualDensity.compact,
              color: AppColors.error,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(
            begin: -0.1,
            end: 0,
            duration: 300.ms,
            curve: Curves.easeOutCubic,
          );
    });
  }

  /// Aktif filtrelere göre chip'leri oluşturur
  List<Widget> _buildFilterChips(BuildContext context) {
    final List<Widget> chips = [];

    // Hesap filtresi
    if (controller.selectedAccount.value != null) {
      chips.add(_buildChip(
        context: context,
        label: controller.selectedAccount.value!.name,
        onTap: () => FilterBottomSheet.show(context, controller),
        color: AppColors.primary,
      ));
    }

    // Kategori filtresi
    if (controller.selectedCategory.value != null) {
      // Kategori tipine göre renk belirle
      final Color categoryColor =
          controller.selectedCategory.value!.type == CategoryType.Income
              ? AppColors.income
              : AppColors.expense;

      chips.add(_buildChip(
        context: context,
        label: controller.selectedCategory.value!.name,
        onTap: () => FilterBottomSheet.show(context, controller),
        color: categoryColor,
      ));
    }

    // İşlem tipi filtresi
    if (controller.selectedType.value != null) {
      final bool isExpense =
          controller.selectedType.value == CategoryType.Expense;
      chips.add(_buildChip(
        context: context,
        label: isExpense ? 'Gider' : 'Gelir',
        onTap: () => FilterBottomSheet.show(context, controller),
        color: isExpense ? AppColors.expense : AppColors.income,
      ));
    }

    // Tarih filtresi
    if (controller.selectedStartDate.value != null) {
      chips.add(_buildChip(
        context: context,
        label:
            '${DateFormat('d MMM', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('d MMM', 'tr_TR').format(controller.selectedEndDate.value!)}',
        onTap: () => FilterBottomSheet.show(context, controller),
        color: AppColors.info,
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
        chips.add(_buildChip(
          context: context,
          label: periodText,
          onTap: () => FilterBottomSheet.show(context, controller),
          color: AppColors.info,
        ));
      }
    }

    return chips;
  }

  /// Bütçe ekranındaki gibi filtre chip'i oluşturur
  Widget _buildChip({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
