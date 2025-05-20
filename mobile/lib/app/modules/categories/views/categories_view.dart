import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/response/category_response_model.dart';
import 'package:mobile/app/modules/categories/controllers/categories_controller.dart';
import 'package:mobile/app/modules/categories/views/widgets/category_form_sheet.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/widgets/content_view.dart';
import 'package:mobile/app/widgets/empty_state_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

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
      body: ContentView(
        isLoading: controller.isLoading,
        errorMessage: controller.errorMessage,
        onRetry: () => controller.loadCategories(),
        emptyStateView: EmptyStateView(
          icon: Icons.category_outlined,
          title: 'Henüz kategori yok',
          message: 'Yeni bir kategori ekleyerek başlayabilirsiniz.',
          actionText: 'Kategori Ekle',
          onAction: () => _showCategoryFormSheet(context),
        ),
        contentView: Column(
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
        ),
      ),
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.category,
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
          isIncome ? 'Gelir Kategorisi' : 'Gider Kategorisi',
          style: Get.textTheme.bodySmall!.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: canEdit
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showCategoryFormSheet(Get.context!, category: category);
                      break;
                    case 'delete':
                      controller.deleteCategory(category.id);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Sil'),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  // Arama dialog'unu göster
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategori Ara'),
        content: TextField(
          onChanged: controller.updateSearchQuery,
          decoration: const InputDecoration(
            hintText: 'Kategori adı...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.updateSearchQuery('');
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  // Kategori form sheet'ini göster
  void _showCategoryFormSheet(BuildContext context, {CategoryModel? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFormSheet(
        category: category,
      ),
    );
  }
}
