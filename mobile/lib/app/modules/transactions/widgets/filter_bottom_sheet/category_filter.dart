import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/response/category_response_model.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/dropdown.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/filter_section_title.dart';

class CategoryFilter extends StatelessWidget {
  final TransactionsController controller;

  const CategoryFilter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionTitle(title: 'Kategori'),
        Obx(
          () => DropDown<CategoryModel?>(
            value: controller.selectedCategory.value,
            items: [
              const DropdownMenuItem<CategoryModel?>(
                value: null,
                child: Text('Tüm Kategoriler'),
              ),
              ...controller.filterCategories.map(
                (category) => DropdownMenuItem<CategoryModel>(
                  value: category,
                  child: Text(category.name, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: (value) => controller.selectedCategory.value = value,
            icon: Icons.category_outlined,
          ),
        ),
      ],
    );
  }
}
