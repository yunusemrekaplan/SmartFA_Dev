import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/response/category_response_model.dart';
import 'package:mobile/app/modules/categories/controllers/categories_controller.dart';
import 'package:mobile/app/modules/categories/widgets/icon_picker.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

class CategoryFormSheet extends StatelessWidget {
  final CategoryModel? category;

  const CategoryFormSheet({
    super.key,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesController>();

    // Düzenleme modu ise formu doldur
    if (category != null) {
      controller.startEdit(category!);
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 24,
        right: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tutamac ve başlık
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Obx(() => Text(
                controller.isEditMode.value
                    ? 'Kategori Düzenle'
                    : 'Yeni Kategori Ekle',
                style: Get.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              )),

          const SizedBox(height: 16),

          // Kategori adı
          TextField(
            controller: controller.nameController,
            decoration: InputDecoration(
              labelText: 'Kategori Adı',
              hintText: 'Örn: Market, Maaş, Faturalar',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
              ),
              prefixIcon: const Icon(Icons.label_outline),
            ),
          ),

          const SizedBox(height: 16),

          // Kategori tipini seçme (gelir/gider)
          Text(
            'Kategori Türü',
            style: Get.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Gider',
                      icon: Icons.arrow_downward,
                      type: CategoryType.Expense,
                      currentType: controller.formCategoryType.value,
                      isEditMode: controller.isEditMode.value,
                      onTap: () {
                        if (!controller.isEditMode.value) {
                          controller.formCategoryType.value =
                              CategoryType.Expense;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Gelir',
                      icon: Icons.arrow_upward,
                      type: CategoryType.Income,
                      currentType: controller.formCategoryType.value,
                      isEditMode: controller.isEditMode.value,
                      onTap: () {
                        if (!controller.isEditMode.value) {
                          controller.formCategoryType.value =
                              CategoryType.Income;
                        }
                      },
                    ),
                  ),
                ],
              )),

          const SizedBox(height: 16),

          // İkon seçici
          Text(
            'Kategori İkonu',
            style: Get.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          const IconPicker(),

          const SizedBox(height: 24),

          // Butonlar
          Row(
            children: [
              // İptal butonu
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.cancelEdit();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.kBorderRadius),
                    ),
                  ),
                  child: const Text('İptal'),
                ),
              ),
              const SizedBox(width: 16),
              // Kaydet butonu
              Expanded(
                child: Obx(() => FilledButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              await controller.submitForm();
                              if (!controller.isLoading.value) {
                                Get.back();
                              }
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.kBorderRadius),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              controller.isEditMode.value ? 'Güncelle' : 'Ekle',
                            ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Kategori türü seçim butonu
  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required CategoryType type,
    required CategoryType currentType,
    required bool isEditMode,
    required VoidCallback onTap,
  }) {
    final bool isSelected = type == currentType;
    final Color color =
        type == CategoryType.Income ? AppColors.income : AppColors.expense;

    return Opacity(
      opacity: isEditMode ? 0.5 : 1.0, // Düzenleme modunda soluk göster
      child: InkWell(
        onTap: isEditMode ? null : onTap, // Düzenleme modunda değiştirilemez
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withOpacity(0.1) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Get.textTheme.labelLarge!.copyWith(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
