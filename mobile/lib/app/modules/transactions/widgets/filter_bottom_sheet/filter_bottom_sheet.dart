import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// İşlem filtreleme için bottom sheet widget'ı
class FilterBottomSheet extends StatelessWidget {
  final TransactionsController controller;

  const FilterBottomSheet({super.key, required this.controller});

  static void show(BuildContext context, TransactionsController controller) {
    controller.startFiltering();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(controller: controller),
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
                      'İşlemleri Filtrele',
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
                    controller.clearFilters();
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
                  // İşlem Tipi Filtreleri
                  Text(
                    'İşlem Tipine Göre',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // İşlem tipi (gelir/gider) seçim butonları
                  Obx(() => Row(
                        children: [
                          _buildTypeFilterButton(
                            context: context,
                            label: 'Tümü',
                            selected: controller.tempType.value == null,
                            icon: Icons.sync_alt_rounded,
                            color: AppColors.primary,
                            onTap: () => controller.selectTypeFilter(null),
                          ),
                          const SizedBox(width: 8),
                          _buildTypeFilterButton(
                            context: context,
                            label: 'Gelir',
                            selected: controller.tempType.value == CategoryType.Income,
                            icon: Icons.arrow_upward_rounded,
                            color: AppColors.income,
                            onTap: () => controller.selectTypeFilter(CategoryType.Income),
                          ),
                          const SizedBox(width: 8),
                          _buildTypeFilterButton(
                            context: context,
                            label: 'Gider',
                            selected: controller.tempType.value == CategoryType.Expense,
                            icon: Icons.arrow_downward_rounded,
                            color: AppColors.expense,
                            onTap: () => controller.selectTypeFilter(CategoryType.Expense),
                          ),
                        ],
                      )).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // Hızlı Tarih Filtreleri
                  Text(
                    'Tarih Aralığı',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Hızlı tarih filtreleri
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildDateFilterChip(
                            label: 'Bugün',
                            selected: controller.tempQuickDate.value == 'today',
                            onTap: () => controller.setQuickDateFilter('today'),
                          ),
                          _buildDateFilterChip(
                            label: 'Dün',
                            selected: controller.tempQuickDate.value == 'yesterday',
                            onTap: () => controller.setQuickDateFilter('yesterday'),
                          ),
                          _buildDateFilterChip(
                            label: 'Bu Hafta',
                            selected: controller.tempQuickDate.value == 'thisWeek',
                            onTap: () => controller.setQuickDateFilter('thisWeek'),
                          ),
                          _buildDateFilterChip(
                            label: 'Bu Ay',
                            selected: controller.tempQuickDate.value == 'thisMonth',
                            onTap: () => controller.setQuickDateFilter('thisMonth'),
                          ),
                          _buildDateFilterChip(
                            label: 'Geçen Ay',
                            selected: controller.tempQuickDate.value == 'lastMonth',
                            onTap: () => controller.setQuickDateFilter('lastMonth'),
                          ),
                          _buildDateFilterChip(
                            label: 'Son 3 Ay',
                            selected: controller.tempQuickDate.value == 'last3Months',
                            onTap: () => controller.setQuickDateFilter('last3Months'),
                          ),
                        ],
                      )).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                  const SizedBox(height: 8),

                  // Özel Tarih Aralığı Seçici
                  OutlinedButton.icon(
                    icon: Icon(Icons.calendar_month, color: AppColors.primary),
                    label: Text('Özel Tarih Aralığı Seç'),
                    onPressed: () => controller.selectDateRange(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

                  const SizedBox(height: 24),

                  // Kategori Filtreleri
                  Text(
                    'Kategorilere Göre',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Kategori arama
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Kategori adına göre ara',
                      prefixIcon: const Icon(Icons.search),
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
                    onChanged: (query) {
                      // Kategori araması (controller'a eklenecek)
                    },
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                  const SizedBox(height: 12),

                  // Kategori seçim chip'leri (filtrelenebilen)
                  Obx(() {
                    if (controller.filterCategories.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Kategori bulunamadı',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.filterCategories.map((category) {
                        final isSelected = controller.tempCategory.value?.id == category.id;
                        final isIncome = category.type == CategoryType.Income;
                        final chipColor = isIncome ? AppColors.income : AppColors.expense;

                        return FilterChip(
                          label: Text(category.name),
                          selected: isSelected,
                          checkmarkColor: Colors.white,
                          selectedColor: chipColor,
                          backgroundColor: AppColors.surfaceVariant,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          avatar: Icon(
                            category.iconName != null && category.iconName!.isNotEmpty
                                ? IconData(int.parse(category.iconName!),
                                    fontFamily: 'MaterialIcons')
                                : Icons.category_outlined,
                            size: 16,
                            color: isSelected ? Colors.white : chipColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? chipColor : AppColors.border,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              controller.selectCategoryFilter(category);
                            } else {
                              controller.selectCategoryFilter(null);
                            }
                          },
                        ).animate().fadeIn(duration: 200.ms);
                      }).toList(),
                    );
                  }).animate().fadeIn(duration: 300.ms, delay: 250.ms),

                  const SizedBox(height: 24),

                  // Hesap Filtreleri
                  Text(
                    'Hesaplara Göre',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Hesap seçim chip'leri
                  Obx(() {
                    if (controller.filterAccounts.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Hesap bulunamadı',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.filterAccounts.map((account) {
                        final isSelected = controller.tempAccount.value?.id == account.id;

                        return FilterChip(
                          label: Text(account.name),
                          selected: isSelected,
                          checkmarkColor: Colors.white,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceVariant,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          avatar: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              controller.selectAccountFilter(account);
                            } else {
                              controller.selectAccountFilter(null);
                            }
                          },
                        ).animate().fadeIn(duration: 200.ms);
                      }).toList(),
                    );
                  }).animate().fadeIn(duration: 300.ms, delay: 300.ms),

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
                          _buildSortChip(
                            label: 'En Yeni',
                            isSelected: controller.tempSortCriteria.value == 'date_desc',
                            onTap: () => controller.setSortingCriteria('date_desc'),
                          ),
                          _buildSortChip(
                            label: 'En Eski',
                            isSelected: controller.tempSortCriteria.value == 'date_asc',
                            onTap: () => controller.setSortingCriteria('date_asc'),
                          ),
                          _buildSortChip(
                            label: 'Tutar (↑)',
                            isSelected: controller.tempSortCriteria.value == 'amount_asc',
                            onTap: () => controller.setSortingCriteria('amount_asc'),
                          ),
                          _buildSortChip(
                            label: 'Tutar (↓)',
                            isSelected: controller.tempSortCriteria.value == 'amount_desc',
                            onTap: () => controller.setSortingCriteria('amount_desc'),
                          ),
                        ],
                      )).animate().fadeIn(duration: 300.ms, delay: 350.ms),
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
                    onPressed: () {
                      controller.applyFilters();
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
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

  /// İşlem tipi filtre butonu
  Widget _buildTypeFilterButton({
    required BuildContext context,
    required String label,
    required bool selected,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? color : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? color : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tarih filtre chip'i
  Widget _buildDateFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) => onTap(),
      selectedColor: AppColors.info.withOpacity(0.2),
      backgroundColor: AppColors.surfaceVariant,
      labelStyle: TextStyle(
        color: selected ? AppColors.info : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.info : AppColors.border,
          width: selected ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  /// Sıralama chip'i
  Widget _buildSortChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          onTap();
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.15),
      backgroundColor: AppColors.surfaceVariant,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
