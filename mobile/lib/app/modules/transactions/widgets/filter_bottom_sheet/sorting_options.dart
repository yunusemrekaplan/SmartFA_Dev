import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/filter_section_title.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/sort_option_chip.dart';

class SortingOptions extends StatelessWidget {
  final TransactionsController controller;

  const SortingOptions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionTitle(title: 'Sıralama'),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SortOptionChip(
                label: 'Tarih ↓',
                isSelected: controller.sortCriteria.value == 'date_desc',
                onSelected: () => controller.sortCriteria.value = 'date_desc',
              ),
              SortOptionChip(
                label: 'Tarih ↑',
                isSelected: controller.sortCriteria.value == 'date_asc',
                onSelected: () => controller.sortCriteria.value = 'date_asc',
              ),
              SortOptionChip(
                label: 'Tutar ↓',
                isSelected: controller.sortCriteria.value == 'amount_desc',
                onSelected: () => controller.sortCriteria.value = 'amount_desc',
              ),
              SortOptionChip(
                label: 'Tutar ↑',
                isSelected: controller.sortCriteria.value == 'amount_asc',
                onSelected: () => controller.sortCriteria.value = 'amount_asc',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
