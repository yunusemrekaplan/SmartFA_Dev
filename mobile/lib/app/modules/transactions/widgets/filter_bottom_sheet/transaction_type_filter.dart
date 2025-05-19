import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/filter_section_title.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/type_filter_button.dart';
import 'package:mobile/app/theme/app_colors.dart';

class TransactionTypeFilter extends StatelessWidget {
  final TransactionsController controller;

  const TransactionTypeFilter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionTitle(title: 'İşlem Tipi'),
        Obx(() => Row(
              children: [
                TypeFilterButton(
                  title: 'Tümü',
                  icon: Icons.sync_alt_rounded,
                  isSelected: controller.selectedType.value == null,
                  onTap: () => controller.selectTypeFilter(null),
                ),
                const SizedBox(width: 12),
                TypeFilterButton(
                  title: 'Gelir',
                  icon: Icons.arrow_upward,
                  isSelected:
                      controller.selectedType.value == CategoryType.Income,
                  onTap: () => controller.selectTypeFilter(CategoryType.Income),
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                TypeFilterButton(
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
      ],
    );
  }
}
