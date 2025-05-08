import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/budgets/Widgets/filter_option.dart';
import 'package:mobile/app/modules/budgets/Widgets/sort_chip.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Bütçe filtreleme için bottom sheet widget'ı
class BudgetFilterBottomSheet extends StatelessWidget {
  final BudgetsController controller;

  const BudgetFilterBottomSheet({
    Key? key,
    required this.controller,
  }) : super(key: key);

  static void show(BuildContext context, BudgetsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetFilterBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tutamac
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Başlık
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Bütçeleri Filtrele',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Sıfırla'),
                  onPressed: () {
                    controller.resetFilters();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Kaydırılabilir içerik
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Arama kutusu
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Kategori adına göre ara',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          Obx(() => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      controller.updateSearchQuery(''),
                                )
                              : const SizedBox.shrink()),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: controller.updateSearchQuery,
                    textInputAction: TextInputAction.search,
                  ),

                  const SizedBox(height: 24),

                  // Kategori Filtreleri - YENİ
                  Text(
                    'Kategorilere Göre',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Kategori filtreleme chip'leri
                  Obx(() {
                    // Mevcut bütçelerin kategorilerini topla (tekrar edilenleri hariç tut)
                    final categories = <int, String>{};
                    for (final budget in controller.budgetList) {
                      categories[budget.categoryId] = budget.categoryName;
                    }

                    if (categories.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Filtrelenecek kategori bulunamadı',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.entries.map((entry) {
                        final isSelected =
                            controller.selectedCategoryIds.contains(entry.key);
                        return FilterChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          checkmarkColor: Colors.white,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceVariant,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            controller.toggleCategoryFilter(entry.key);
                          },
                        ).animate().fadeIn(duration: 200.ms);
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Bütçe Durumu Filtreleri
                  Text(
                    'Bütçe Durumuna Göre',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Bütçe durum filtreleri
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FilterOption(
                            title: 'Tüm Bütçeler',
                            subtitle: 'Herhangi bir filtre uygulanmaz',
                            icon: Icons.all_inclusive,
                            isSelected: controller.activeFilter.value ==
                                BudgetFilterType.all,
                            color: AppColors.primary,
                            onTap: () =>
                                controller.changeFilter(BudgetFilterType.all),
                          ),
                          FilterOption(
                            title: 'Bütçe Aşımı Olanlar',
                            subtitle: 'Limit aşılmış bütçeler',
                            icon: Icons.error_outline_rounded,
                            isSelected: controller.activeFilter.value ==
                                BudgetFilterType.overLimit,
                            color: AppColors.error,
                            onTap: () => controller
                                .changeFilter(BudgetFilterType.overLimit),
                          ),
                          FilterOption(
                            title: 'Limite Yaklaşanlar',
                            subtitle: 'Bütçenin %85 ve üzerini kullananlar',
                            icon: Icons.warning_amber_rounded,
                            isSelected: controller.activeFilter.value ==
                                BudgetFilterType.nearLimit,
                            color: AppColors.warning,
                            onTap: () => controller
                                .changeFilter(BudgetFilterType.nearLimit),
                          ),
                          FilterOption(
                            title: 'Normal Bütçeler',
                            subtitle: 'Bütçenin %85\'inden azını kullananlar',
                            icon: Icons.check_circle_outline_rounded,
                            isSelected: controller.activeFilter.value ==
                                BudgetFilterType.underBudget,
                            color: AppColors.success,
                            onTap: () => controller
                                .changeFilter(BudgetFilterType.underBudget),
                          ),
                        ],
                      )),

                  const SizedBox(height: 24),

                  // Sıralama Seçenekleri
                  Text(
                    'Sıralama',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Sıralama seçenekleri
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SortChip(
                            label: 'Kategori A-Z',
                            isSelected: controller.activeSortType.value ==
                                BudgetSortType.categoryAZ,
                            onTap: () => controller
                                .changeSortType(BudgetSortType.categoryAZ),
                          ),
                          SortChip(
                            label: 'Kategori Z-A',
                            isSelected: controller.activeSortType.value ==
                                BudgetSortType.categoryZA,
                            onTap: () => controller
                                .changeSortType(BudgetSortType.categoryZA),
                          ),
                          SortChip(
                            label: 'Bütçe ↓',
                            isSelected: controller.activeSortType.value ==
                                BudgetSortType.amountHighToLow,
                            onTap: () => controller
                                .changeSortType(BudgetSortType.amountHighToLow),
                          ),
                          SortChip(
                            label: 'Bütçe ↑',
                            isSelected: controller.activeSortType.value ==
                                BudgetSortType.amountLowToHigh,
                            onTap: () => controller
                                .changeSortType(BudgetSortType.amountLowToHigh),
                          ),
                          SortChip(
                            label: 'Harcanan ↓',
                            isSelected: controller.activeSortType.value ==
                                BudgetSortType.spentHighToLow,
                            onTap: () => controller
                                .changeSortType(BudgetSortType.spentHighToLow),
                          ),
                          SortChip(
                            label: 'Harcanan ↑',
                            isSelected: controller.activeSortType.value ==
                                BudgetSortType.spentLowToHigh,
                            onTap: () => controller
                                .changeSortType(BudgetSortType.spentLowToHigh),
                          ),
                          SortChip(
                            label: 'Kalan ↓',
                            isSelected: controller.activeSortType.value ==
                                BudgetSortType.remainingHighToLow,
                            onTap: () => controller.changeSortType(
                                BudgetSortType.remainingHighToLow),
                          ),
                          SortChip(
                            label: 'Kalan ↑',
                            isSelected: controller.activeSortType.value ==
                                BudgetSortType.remainingLowToHigh,
                            onTap: () => controller.changeSortType(
                                BudgetSortType.remainingLowToHigh),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tamam butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.kBorderRadius),
                      ),
                    ),
                    child: const Text('Tamam'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
