import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/core/services/dialog/i_dialog_service.dart';
import 'package:mobile/app/core/services/snackbar/i_snackbar_service.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/request/category_request_models.dart';
import 'package:mobile/app/domain/models/response/category_response_model.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/core/services/base_controller_mixin.dart';

/// Kategoriler ekranının state'ini ve iş mantığını yöneten GetX controller.
class CategoriesController extends GetxController with BaseControllerMixin {
  final ICategoryRepository _categoryRepository;
  final _snackbarService = Get.find<ISnackbarService>();

  CategoriesController({
    required ICategoryRepository categoryRepository,
  }) : _categoryRepository = categoryRepository;

  // --- State Değişkenleri ---

  // Kategori listeleri
  final RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  final RxList<CategoryModel> displayedCategories = <CategoryModel>[].obs;

  // Kullanıcı kategori listeleri
  final RxList<CategoryModel> userCategories = <CategoryModel>[].obs;

  // Ön tanımlı kategori listeleri
  final RxList<CategoryModel> predefinedCategories = <CategoryModel>[].obs;

  // Filtreleme için
  final Rx<CategoryType?> selectedType = Rx<CategoryType?>(null);
  final RxString searchQuery = ''.obs;

  // Form için
  final RxBool isEditMode = false.obs;
  final RxInt editCategoryId = RxInt(0);
  final TextEditingController nameController = TextEditingController();
  final Rx<CategoryType> formCategoryType = CategoryType.Expense.obs;
  final RxString selectedIcon = ''.obs;

  // --- Lifecycle Metotları ---

  @override
  void onInit() {
    super.onInit();
    loadData(
      fetchFunc: _fetchCategories,
      loadingErrorMessage: "Kategoriler yüklenirken bir hata oluştu.",
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  // --- Veri Çekme Metotları ---

  /// Tüm kategorileri yükler
  Future<void> _fetchCategories() async {
    // İlk olarak tüm kategorileri temizle
    allCategories.clear();
    userCategories.clear();
    predefinedCategories.clear();
    displayedCategories.clear();

    // Gelir kategorilerini getir
    await _fetchCategoriesByType(CategoryType.Income);
    // Gider kategorilerini getir
    await _fetchCategoriesByType(CategoryType.Expense);

    // Kategorileri filtrele ve görüntüle
    _filterCategories();
  }

  /// Kategorileri yeniden yüklemek için public metod
  Future<void> loadCategories() async {
    await loadData(
      fetchFunc: _fetchCategories,
      loadingErrorMessage: "Kategoriler yüklenirken bir hata oluştu.",
    );
  }

  /// Belirli bir türdeki kategorileri getirir
  Future<void> _fetchCategoriesByType(CategoryType type) async {
    final result = await _categoryRepository.getCategories(type);

    result.when(
      success: (categories) {
        // Tüm kategorilere ekle
        allCategories.addAll(categories);

        // Türe göre ayrıştır
        final predefined = categories.where((c) => c.isPredefined).toList();
        final userOwned = categories.where((c) => !c.isPredefined).toList();

        predefinedCategories.addAll(predefined);
        userCategories.addAll(userOwned);
      },
      failure: (error) {
        // Hata durumunda mixin'deki errorMessage güncellenir
        errorMessage.value = "Kategoriler yüklenirken hata: ${error.message}";
        throw error; // BaseControllerMixin için hatayı fırlat
      },
    );
  }

  // --- Kategori İşlemleri ---

  /// Yeni kategori oluştur
  Future<void> createCategory() async {
    if (nameController.text.trim().isEmpty) {
      _snackbarService.showWarning(
        message: "Kategori adı boş olamaz",
        title: "Uyarı",
      );
      return;
    }

    if (selectedIcon.value.isEmpty) {
      _snackbarService.showWarning(
        message: "Lütfen bir ikon seçin",
        title: "Uyarı",
      );
      return;
    }

    final categoryData = CreateCategoryRequestModel(
      name: nameController.text.trim(),
      type: formCategoryType.value,
      iconName: selectedIcon.value,
    );

    isLoading.value = true;

    try {
      final result = await _categoryRepository.createCategory(categoryData);

      result.when(
        success: (category) {
          // Listeye ekle ve filtrelemeyi uygula
          userCategories.add(category);
          allCategories.add(category);
          _filterCategories();

          // Formu temizle
          _resetForm();

          _snackbarService.showSuccess(
            message: "${category.name} kategorisi başarıyla oluşturuldu",
            title: "Başarılı",
          );
        },
        failure: (error) {
          _snackbarService.showError(
            message: "Kategori oluşturulurken hata: ${error.message}",
            title: "Hata",
          );
        },
      );
    } catch (e) {
      _snackbarService.showError(
        message: "Beklenmeyen bir hata oluştu",
        title: "Hata",
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Kategoriyi güncelle
  Future<void> updateCategory() async {
    if (editCategoryId.value <= 0) {
      _snackbarService.showWarning(
        message: "Güncellenecek kategori bulunamadı",
        title: "Uyarı",
      );
      return;
    }

    if (nameController.text.trim().isEmpty) {
      _snackbarService.showWarning(
        message: "Kategori adı boş olamaz",
        title: "Uyarı",
      );
      return;
    }

    if (selectedIcon.value.isEmpty) {
      _snackbarService.showWarning(
        message: "Lütfen bir ikon seçin",
        title: "Uyarı",
      );
      return;
    }

    final categoryData = UpdateCategoryRequestModel(
      name: nameController.text.trim(),
      iconName: selectedIcon.value,
    );

    isLoading.value = true;

    try {
      final result = await _categoryRepository.updateCategory(
        editCategoryId.value,
        categoryData,
      );

      result.when(
        success: (_) {
          // Kategoriyi listede güncelle
          final index =
              userCategories.indexWhere((c) => c.id == editCategoryId.value);
          if (index >= 0) {
            final oldCategory = userCategories[index];
            final updatedCategory = CategoryModel(
              id: oldCategory.id,
              name: nameController.text.trim(),
              type: oldCategory.type,
              iconName: selectedIcon.value,
              isPredefined: false,
            );

            userCategories[index] = updatedCategory;

            // allCategories listesini de güncelle
            final allIndex =
                allCategories.indexWhere((c) => c.id == editCategoryId.value);
            if (allIndex >= 0) {
              allCategories[allIndex] = updatedCategory;
            }

            _filterCategories();
          }

          // Formu temizle ve düzenleme modundan çık
          _resetForm();
          isEditMode.value = false;

          _snackbarService.showSuccess(
            message: "Kategori başarıyla güncellendi",
            title: "Başarılı",
          );
        },
        failure: (error) {
          _snackbarService.showError(
            message: "Kategori güncellenirken hata: ${error.message}",
            title: "Hata",
          );
        },
      );
    } catch (e) {
      _snackbarService.showError(
        message: "Beklenmeyen bir hata oluştu",
        title: "Hata",
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Kategoriyi sil
  Future<void> deleteCategory(int categoryId) async {
    final result = await Get.find<IDialogService>().showDeleteConfirmation(
      title: "Kategoriyi Sil",
      message: "Bu kategoriyi silmek istediğinizden emin misiniz?",
    );

    if (result != true) return;

    isLoading.value = true;

    try {
      final result = await _categoryRepository.deleteCategory(categoryId);

      result.when(
        success: (_) {
          // Kategoriyi listelerden kaldır
          userCategories.removeWhere((c) => c.id == categoryId);
          allCategories.removeWhere((c) => c.id == categoryId);
          _filterCategories();

          _snackbarService.showSuccess(
            message: "Kategori başarıyla silindi",
            title: "Başarılı",
          );
        },
        failure: (error) {
          _snackbarService.showError(
            message: "Kategori silinirken hata: ${error.message}",
            title: "Hata",
          );
        },
      );
    } catch (e) {
      _snackbarService.showError(
        message: "Beklenmeyen bir hata oluştu",
        title: "Hata",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- Form İşlemleri ---

  /// Düzenleme modunu başlat ve formu doldur
  void startEdit(CategoryModel category) {
    isEditMode.value = true;
    editCategoryId.value = category.id;
    nameController.text = category.name;
    formCategoryType.value = category.type;
    selectedIcon.value = category.iconName ?? '';
  }

  /// Formu temizle ve düzenleme modundan çık
  void _resetForm() {
    isEditMode.value = false;
    editCategoryId.value = 0;
    nameController.clear();
    selectedIcon.value = '';
  }

  /// İptal et ve forma temizle
  void cancelEdit() {
    _resetForm();
  }

  /// Form gönderim işlemi - oluşturma veya güncelleme
  Future<void> submitForm() async {
    if (isEditMode.value) {
      await updateCategory();
    } else {
      await createCategory();
    }
  }

  // --- Filtreleme İşlemleri ---

  /// Kategorileri filtrele
  void _filterCategories() {
    var filtered = List<CategoryModel>.from(allCategories);

    // Tür filtresi
    if (selectedType.value != null) {
      filtered = filtered.where((c) => c.type == selectedType.value).toList();
    }

    // Arama filtresi
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered =
          filtered.where((c) => c.name.toLowerCase().contains(query)).toList();
    }

    // Filtrelenmiş listeyi güncelle
    displayedCategories.assignAll(filtered);
  }

  /// Tür filtresini güncelle
  void setTypeFilter(CategoryType? type) {
    selectedType.value = type;
    _filterCategories();
  }

  /// Arama sorgusunu güncelle
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _filterCategories();
  }

  // --- İkon İşlemleri ---

  /// İkon seçimi için
  void selectIcon(String iconCode) {
    selectedIcon.value = iconCode;
  }

  /// Bir ikonun seçili olup olmadığını kontrol et
  bool isIconSelected(String iconCode) {
    return selectedIcon.value == iconCode;
  }

  /// İkon verisinden Flutter ikonu oluştur
  IconData? getIconData(String? iconString) {
    if (iconString == null || iconString.isEmpty) {
      return Icons.category;
    }

    try {
      return IconData(
        int.parse(iconString),
        fontFamily: 'MaterialIcons',
      );
    } catch (e) {
      // Parse hatası durumunda varsayılan
      return Icons.category;
    }
  }
}
