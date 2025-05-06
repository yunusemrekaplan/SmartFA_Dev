import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Aktif filtreleri gösteren Chip'leri içeren satır Widget'ı
class ActiveFiltersRow extends StatelessWidget {
  final TransactionsController controller;

  const ActiveFiltersRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Widget> chips = [];

      if (controller.selectedAccount.value != null) {
        chips.add(_buildFilterChip(
          label: 'Hesap: ${controller.selectedAccount.value!.name}',
          onDeleted: () => controller.selectAccountFilter(null),
          icon: Icons.account_balance_wallet_outlined,
        ));
      }

      if (controller.selectedCategory.value != null) {
        chips.add(_buildFilterChip(
          label: 'Kategori: ${controller.selectedCategory.value!.name}',
          onDeleted: () => controller.selectCategoryFilter(null),
          icon: Icons.category_outlined,
        ));
      }

      if (controller.selectedType.value != null) {
        chips.add(_buildFilterChip(
          label:
              controller.selectedType.value == CategoryType.Expense ? 'Tip: Gider' : 'Tip: Gelir',
          onDeleted: () => controller.selectTypeFilter(null),
          icon: controller.selectedType.value == CategoryType.Expense
              ? Icons.arrow_downward
              : Icons.arrow_upward,
        ));
      }

      if (controller.selectedStartDate.value != null) {
        chips.add(_buildFilterChip(
          label:
              'Tarih: ${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedEndDate.value!)}',
          onDeleted: () {
            controller.selectedStartDate.value = null;
            controller.selectedEndDate.value = null;
            controller.applyFilters();
          },
          icon: Icons.date_range,
        ));
      }

      if (chips.isEmpty) {
        return const SizedBox.shrink();
      }

      // Kaydırılabilir filtre chip'leri
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: chips.length,
          itemBuilder: (context, index) => chips[index],
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      );
    });
  }

  /// Özel tasarlanmış filtre chip'i
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
    required IconData icon,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label, style: Get.theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
      onDeleted: onDeleted,
      deleteIconColor: Colors.black54,
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
