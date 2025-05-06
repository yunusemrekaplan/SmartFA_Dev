import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Filtreleme seçeneklerini gösteren Bottom Sheet Widget'ı
class FilterBottomSheet extends StatelessWidget {
  final TransactionsController controller;

  const FilterBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('İşlem Filtreleri',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(height: 24),

            // İşlem Tipi Seçimi (Gelir/Gider)
            _buildFilterSectionTitle(context, 'İşlem Tipi'),
            Obx(() => Row(
              children: [
                _buildTypeFilterButton(
                  title: 'Tümü',
                  icon: Icons.sync_alt_rounded,
                  isSelected: controller.selectedType.value == null,
                  onTap: () => controller.selectTypeFilter(null),
                ),
                const SizedBox(width: 12),
                _buildTypeFilterButton(
                  title: 'Gelir',
                  icon: Icons.arrow_upward,
                  isSelected:
                  controller.selectedType.value == CategoryType.Income,
                  onTap: () =>
                      controller.selectTypeFilter(CategoryType.Income),
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                _buildTypeFilterButton(
                  title: 'Gider',
                  icon: Icons.arrow_downward,
                  isSelected:
                  controller.selectedType.value == CategoryType.Expense,
                  onTap: () =>
                      controller.selectTypeFilter(CategoryType.Expense),
                  color: AppColors.error,
                ),
              ],
            )),

            const SizedBox(height: 24),

            // Tarih Aralığı
            _buildFilterSectionTitle(context, 'Tarih Aralığı'),
            _buildFilterOption(
                context: context,
                leadingIcon: Icons.date_range_outlined,
                title: 'Tarih Aralığı Seçin',
                subtitle: Obx(() => Text(controller.selectedStartDate.value ==
                    null
                    ? 'Tüm Tarihler'
                    : '${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedEndDate.value!)}')),
                onTap: () {
                  Get.back();
                  controller.selectDateRange(context);
                }),

            // Hızlı Tarih Aralığı Butonları
            _buildQuickDateFilterButtons(),

            const SizedBox(height: 16),

            // Hesap Seçimi
            _buildFilterSectionTitle(context, 'Hesap'),
            Obx(() => _buildDropdown<AccountModel?>(
              value: controller.selectedAccount.value,
              items: [
                const DropdownMenuItem<AccountModel?>(
                  value: null,
                  child: Text('Tüm Hesaplar'),
                ),
                ...controller.filterAccounts
                    .map((account) => DropdownMenuItem<AccountModel>(
                  value: account,
                  child: Text(account.name,
                      overflow: TextOverflow.ellipsis),
                ))
                    .toList(),
              ],
              onChanged: controller.selectAccountFilter,
              icon: Icons.account_balance_wallet_outlined,
            )),

            const SizedBox(height: 16),

            // Kategori Seçimi
            _buildFilterSectionTitle(context, 'Kategori'),
            Obx(() => _buildDropdown<CategoryModel?>(
                  value: controller.selectedCategory.value,
                  items: [
                    const DropdownMenuItem<CategoryModel?>(
                      value: null,
                      child: Text('Tüm Kategoriler'),
                    ),
                    ...controller.filterCategories
                        .map((category) => DropdownMenuItem<CategoryModel>(
                              value: category,
                              child: Text(category.name, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                  ],
                  onChanged: controller.selectCategoryFilter,
                  icon: Icons.category_outlined,
                )),

            const SizedBox(height: 24),

            // Sıralama Seçenekleri
            _buildFilterSectionTitle(context, 'Sıralama'),
            _buildSortingOptions(),

            const SizedBox(height: 24),

            // Eylem Butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearFilters();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Filtreleri Temizle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Uygula'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods for Filter Bottom Sheet ---

  /// Hızlı tarih filtreleme butonları
  Widget _buildQuickDateFilterButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildQuickDateButton(
              'Bugün', () => controller.setQuickDateFilter('today')),
          _buildQuickDateButton(
              'Dün', () => controller.setQuickDateFilter('yesterday')),
          _buildQuickDateButton(
              'Bu Hafta', () => controller.setQuickDateFilter('thisWeek')),
          _buildQuickDateButton(
              'Bu Ay', () => controller.setQuickDateFilter('thisMonth')),
          _buildQuickDateButton(
              'Geçen Ay', () => controller.setQuickDateFilter('lastMonth')),
          _buildQuickDateButton(
              'Son 3 Ay', () => controller.setQuickDateFilter('last3Months')),
        ],
      ),
    );
  }

  /// Hızlı tarih filtre butonu
  Widget _buildQuickDateButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        onTap();
        Get.back();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          color: AppColors.primary.withOpacity(0.05),
        ),
        child: Text(
          title,
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// Sıralama seçenekleri
  Widget _buildSortingOptions() {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSortOptionChip(
          label: 'Tarih ↓',
          isSelected: controller.sortCriteria.value == 'date_desc',
          onSelected: () => controller.setSortingCriteria('date_desc'),
        ),
        _buildSortOptionChip(
          label: 'Tarih ↑',
          isSelected: controller.sortCriteria.value == 'date_asc',
          onSelected: () => controller.setSortingCriteria('date_asc'),
        ),
        _buildSortOptionChip(
          label: 'Tutar ↓',
          isSelected: controller.sortCriteria.value == 'amount_desc',
          onSelected: () => controller.setSortingCriteria('amount_desc'),
        ),
        _buildSortOptionChip(
          label: 'Tutar ↑',
          isSelected: controller.sortCriteria.value == 'amount_asc',
          onSelected: () => controller.setSortingCriteria('amount_asc'),
        ),
      ],
    ));
  }

  /// Sıralama seçeneği chip'i
  Widget _buildSortOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelected();
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: Get.theme.textTheme.bodyMedium?.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  /// Filtre seçeneği
  Widget _buildFilterOption({
    required BuildContext context,
    required IconData leadingIcon,
    required String title,
    required Widget subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          leadingIcon,
          color: AppColors.primary,
        ),
      ),
      title: Text(title),
      subtitle: subtitle,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// Filtre bölüm başlığını oluşturur
  Widget _buildFilterSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Özel tasarlanmış dropdown
  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          hint: const Text('Seçiniz'),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// İşlem tipi filtre butonlarını oluşturur
  Widget _buildTypeFilterButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? AppColors.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? buttonColor.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? buttonColor : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? buttonColor : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: isSelected ? buttonColor : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}