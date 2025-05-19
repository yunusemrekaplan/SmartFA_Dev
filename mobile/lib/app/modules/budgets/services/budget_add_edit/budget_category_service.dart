import 'package:get/get.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/response/category_response_model.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';

/// Kategori yönetim servisi - SRP (Single Responsibility) prensibi
class BudgetCategoryService {
  final ICategoryRepository _categoryRepository;

  // Kategori verileri
  final categories = RxList<CategoryModel>([]);
  final selectedCategoryId = RxnInt(null);
  final selectedCategoryName = RxString('');
  final selectedCategoryIcon = RxString('');
  final isCategoriesLoading = RxBool(false);
  final categoryErrorMessage = RxString('');

  BudgetCategoryService(this._categoryRepository);

  /// Kategorileri yükler
  Future<bool> fetchCategories() async {
    isCategoriesLoading.value = true;
    categoryErrorMessage.value = '';

    try {
      // Gider kategorilerini alıyoruz (bütçe sadece gider kategorileri için oluşturulabilir)
      final result =
          await _categoryRepository.getCategories(CategoryType.Expense);

      return result.when(
        success: (data) {
          categories.assignAll(data);
          return true;
        },
        failure: (error) {
          categoryErrorMessage.value =
              'Kategoriler yüklenirken hata oluştu: ${error.message}';
          return false;
        },
      );
    } catch (e) {
      categoryErrorMessage.value = 'Beklenmeyen bir hata oluştu: $e';
      return false;
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  /// Kategori seçme işlemi
  void selectCategory(int id, String name) {
    selectedCategoryId.value = id;
    selectedCategoryName.value = name;

    // Seçilen kategorinin ikonunu bul
    final category = categories.firstWhereOrNull((c) => c.id == id);
    if (category != null) {
      selectedCategoryIcon.value = category.iconName ?? '';
    }
  }

  /// Düzenleme modu için kategori bilgilerini ayarlar
  void setupCategoryForEdit(int categoryId, String categoryName) {
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = categoryName;

    // Kategoriler yüklendikten sonra icon bulunur
    if (categories.isNotEmpty) {
      final category = categories.firstWhereOrNull((c) => c.id == categoryId);
      if (category != null) {
        selectedCategoryIcon.value = category.iconName ?? '';
      }
    }
  }

  /// Kategori ID'si alır
  int? getCategoryId() => selectedCategoryId.value;
}
