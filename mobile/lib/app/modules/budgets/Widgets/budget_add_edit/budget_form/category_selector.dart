import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/modules/budgets/controllers/budget_add_edit_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

/// Kategori seçici bileşeni - SRP (Single Responsibility) prensibi uygulandı
class CategorySelector extends StatelessWidget {
  final BudgetAddEditController controller;

  const CategorySelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCategoriesLoading.value) {
        return _buildLoadingState();
      }

      if (controller.categories.isEmpty) {
        return _buildEmptyState(context);
      }

      return _buildCategoryDropdown(context);
    });
  }

  /// Yükleme durumu
  Widget _buildLoadingState() {
    return const SizedBox(
      height: 60,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Boş kategori durumu
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        border: Border.all(color: AppColors.border, width: 1),
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

  /// Kategori dropdown bileşeni
  Widget _buildCategoryDropdown(BuildContext context) {
    // Geçerli bir kategori ID'si olup olmadığını kontrol et
    final selectedCategoryId = controller.categoryId.value;
    final isValidCategory = controller.categories.any((category) => category.id == selectedCategoryId);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        border: Border.all(
          color: selectedCategoryId == null || !isValidCategory
              ? AppColors.error.withOpacity(0.5)
              : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: isValidCategory ? selectedCategoryId : null, // Geçerli değilse null yap
          isExpanded: true,
          hint: _buildDropdownHint(),
          icon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
          padding: EdgeInsets.zero,
          items: _buildDropdownItems(context),
          onChanged: _onCategorySelected,
        ),
      ),
    )
        .animate()
        .fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 300),
    )
        .slideY(
      begin: 0.2,
      end: 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  /// Dropdown için ipucu metni
  Widget _buildDropdownHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.category_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Kategori seçin',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Dropdown için öğeleri oluştur
  List<DropdownMenuItem<int>> _buildDropdownItems(BuildContext context) {
    return controller.categories.map((category) {
      return DropdownMenuItem<int>(
        value: category.id,
        child: _buildCategoryItem(context, category),
      );
    }).toList();
  }

  /// Kategori öğesi görünümü
  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _buildCategoryIcon(category),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Kategori ikonu oluştur
  Widget _buildCategoryIcon(CategoryModel category) {
    return category.iconName != null && category.iconName!.isNotEmpty
        ? Icon(
            IconData(int.parse(category.iconName!),
                fontFamily: 'MaterialIcons'),
            color: AppColors.primary,
            size: 20,
          )
        : Icon(
            Icons.category_outlined,
            color: AppColors.primary,
            size: 20,
          );
  }

  /// Kategori seçildiğinde çağrılır
  void _onCategorySelected(int? value) {
    if (value != null) {
      final category = controller.categories.firstWhere((c) => c.id == value);
      controller.selectCategory(value, category.name);
    }
  }
}
