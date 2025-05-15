import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/modules/categories/controllers/categories_controller.dart';
import 'package:mobile/app/modules/categories/views/widgets/category_form_sheet.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/widgets/empty_state_view.dart';
import 'package:mobile/app/widgets/error_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategoriler'),
        actions: [
          // Arama Butonu
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        // Yükleniyor durumu
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Hata durumu
        if (controller.errorMessage.isNotEmpty) {
          return ErrorView(
            message: controller.errorMessage.value,
            onRetry: () => controller.refreshData(
              fetchFunc: () => controller.refreshCategories(),
              refreshErrorMessage: "Kategoriler yenilenirken bir hata oluştu.",
            ),
          );
        }

        // Boş veri durumu
        if (controller.allCategories.isEmpty) {
          return EmptyStateView(
            icon: Icons.category_outlined,
            title: 'Henüz kategori yok',
            message: 'Yeni bir kategori ekleyerek başlayabilirsiniz.',
            actionText: 'Kategori Ekle',
            onAction: () => _showCategoryFormSheet(context),
          );
        }

        // Ana içerik
        return Column(
          children: [
            // Tür filtreleme butonları
            _buildTypeFilterButtons(),

            // Kategori listesi
            Expanded(
              child: Obx(() {
                if (controller.displayedCategories.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.filter_list,
                    title: 'Sonuç bulunamadı',
                    message: 'Arama kriterlerinize uygun kategori bulunamadı.',
                    actionText: 'Filtreleri Temizle',
                    onAction: () {
                      controller.setTypeFilter(null);
                      controller.updateSearchQuery('');
                    },
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Öntanımlı kategoriler
                    ..._buildCategorySectionIfNotEmpty(
                      title: 'Öntanımlı Kategoriler',
                      categories: controller.displayedCategories
                          .where((c) => c.isPredefined)
                          .toList(),
                      canEdit: false,
                    ),

                    const SizedBox(height: 16),

                    // Kullanıcı kategorileri
                    ..._buildCategorySectionIfNotEmpty(
                      title: 'Özel Kategoriler',
                      categories: controller.displayedCategories
                          .where((c) => !c.isPredefined)
                          .toList(),
                      canEdit: true,
                    ),

                    // Boş alan (FAB için)
                    const SizedBox(height: 80),
                  ],
                );
              }),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Tür filtreleme butonları
  Widget _buildTypeFilterButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildFilterButton(
                  label: 'Tümü',
                  isSelected: controller.selectedType.value == null,
                  icon: Icons.category,
                  color: AppColors.primary,
                  onTap: () => controller.setTypeFilter(null),
                )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() => _buildFilterButton(
                  label: 'Gelir',
                  isSelected:
                      controller.selectedType.value == CategoryType.Income,
                  icon: Icons.arrow_upward,
                  color: AppColors.income,
                  onTap: () => controller.setTypeFilter(CategoryType.Income),
                )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() => _buildFilterButton(
                  label: 'Gider',
                  isSelected:
                      controller.selectedType.value == CategoryType.Expense,
                  icon: Icons.arrow_downward,
                  color: AppColors.expense,
                  onTap: () => controller.setTypeFilter(CategoryType.Expense),
                )),
          ),
        ],
      ),
    );
  }

  // Filtre butonu widget'ı
  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kategori bölümü oluşturma
  List<Widget> _buildCategorySectionIfNotEmpty({
    required String title,
    required List<CategoryModel> categories,
    required bool canEdit,
  }) {
    if (categories.isEmpty) {
      return [];
    }

    return [
      Text(
        title,
        style: Get.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 12),
      ...categories.map((category) {
        return _buildCategoryItem(category, canEdit: canEdit)
            .animate()
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.1, end: 0, duration: 300.ms);
      }).toList(),
    ];
  }

  // Tek bir kategori öğesi
  Widget _buildCategoryItem(CategoryModel category, {required bool canEdit}) {
    // Kategori rengini belirle
    final bool isIncome = category.type == CategoryType.Income;
    final Color categoryColor = isIncome ? AppColors.income : AppColors.expense;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            controller.getIconData(category.iconName),
            color: categoryColor,
            size: 20,
          ),
        ),
        title: Text(
          category.name,
          style: Get.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          category.type.name,
          style: Get.textTheme.bodySmall!.copyWith(
            color: categoryColor,
          ),
        ),
        trailing: canEdit
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Düzenle butonu
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    onPressed: () {
                      controller.startEdit(category);
                      _showCategoryFormSheet(Get.context!);
                    },
                  ),
                  // Sil butonu
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () => controller.deleteCategory(category.id),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  // Kategori ekleme/düzenleme bottom sheet'i
  void _showCategoryFormSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategoryFormSheet(),
    );
  }

  // Arama dialogu
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final searchController =
            TextEditingController(text: controller.searchQuery.value);

        return AlertDialog(
          title: const Text('Kategori Ara'),
          content: TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Kategori adı...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              controller.updateSearchQuery(value);
            },
          ),
          actions: [
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Ara'),
              onPressed: () {
                controller.updateSearchQuery(searchController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
