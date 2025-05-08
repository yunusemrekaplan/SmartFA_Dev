import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/budgets/Widgets/filter_chip.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Aktif filtreleri gösteren bar widget'ı
class ActiveFiltersBar extends StatelessWidget {
  final BudgetsController controller;

  const ActiveFiltersBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final bool hasFilters = controller.activeFilter.value != BudgetFilterType.all ||
            controller.selectedCategoryIds.isNotEmpty ||
            controller.searchQuery.isNotEmpty;

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
                    children: [
                      // Filtre tipi göstergesi
                      if (controller.activeFilter.value != BudgetFilterType.all)
                        BudgetFilterChip(
                          label: controller.activeFilter.value == BudgetFilterType.overLimit
                              ? 'Bütçe Aşımı'
                              : controller.activeFilter.value == BudgetFilterType.nearLimit
                                  ? 'Limite Yakın'
                                  : 'Normal Bütçeler',
                          onTap: () {
                            controller.changeFilter(BudgetFilterType.all);
                          },
                          color: controller.activeFilter.value == BudgetFilterType.overLimit
                              ? AppColors.error
                              : controller.activeFilter.value == BudgetFilterType.nearLimit
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),

                      // Arama filtresi göstergesi
                      if (controller.searchQuery.isNotEmpty)
                        BudgetFilterChip(
                          label: '"${controller.searchQuery.value}"',
                          onTap: () {
                            controller.updateSearchQuery('');
                          },
                          color: AppColors.primary,
                        ),

                      // Kategori filtresi göstergesi (sadece kaç kategori seçildiğini gösterir)
                      if (controller.selectedCategoryIds.isNotEmpty)
                        BudgetFilterChip(
                          label: '${controller.selectedCategoryIds.length} Kategori',
                          onTap: () {
                            controller.selectedCategoryIds.clear();
                          },
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),

              // Tüm filtreleri temizle butonu
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: controller.resetFilters,
                tooltip: 'Filtreleri Temizle',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(
              begin: -0.1,
              end: 0,
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}
