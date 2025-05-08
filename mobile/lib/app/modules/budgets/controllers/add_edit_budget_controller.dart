import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/request/budget_request_models.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Bütçe ekleme/düzenleme ekranının controller'ı.
class AddEditBudgetController extends GetxController {
  // Bağımlılıklar
  final IBudgetRepository _budgetRepository;
  final ICategoryRepository _categoryRepository;

  AddEditBudgetController(this._budgetRepository, this._categoryRepository);

  // --- State Değişkenleri ---

  // Form için kullanılacak değişkenler
  final categoryId = RxnInt(null);
  final amount = RxDouble(0.0);
  final month = RxInt(DateTime.now().month);
  final year = RxInt(DateTime.now().year);

  // Seçilen kategori adını göstermek için
  final selectedCategoryName = RxString('');

  // Form State
  final formKey = GlobalKey<FormState>();
  final isLoading = RxBool(false);
  final isEditing = RxBool(false); // Düzenleme modunda mı?
  final budgetId = RxnInt(null); // Düzenleme için ID

  // Kategori listesi
  final categories = RxList<CategoryModel>([]);
  final isCategoriesLoading = RxBool(false);

  // Mesajlar
  final errorMessage = RxString('');

  @override
  void onInit() {
    super.onInit();

    // Kategorileri yükle
    fetchCategories();

    // Düzenleme modu kontrolü
    final BudgetModel? budget = Get.arguments as BudgetModel?;
    if (budget != null) {
      // Düzenleme modu
      isEditing.value = true;
      budgetId.value = budget.id;
      categoryId.value = budget.categoryId;
      selectedCategoryName.value = budget.categoryName;
      amount.value = budget.amount;
      month.value = budget.month;
      year.value = budget.year;
    }
  }

  /// Kategori listesini yükler
  Future<void> fetchCategories() async {
    isCategoriesLoading.value = true;

    // Gider kategorilerini alıyoruz (bütçe sadece gider kategorileri için oluşturulabilir)
    final result =
        await _categoryRepository.getCategories(CategoryType.Expense);

    result.when(
      success: (data) {
        categories.assignAll(data);

        // Eğer düzenleme modunda ve kategori ID'si varsa, kategori adını bul
        if (isEditing.value && categoryId.value != null) {
          final category =
              categories.firstWhereOrNull((c) => c.id == categoryId.value);
          if (category != null) {
            selectedCategoryName.value = category.name;
          }
        }
      },
      failure: (error) {
        errorMessage.value =
            'Kategoriler yüklenirken hata oluştu: ${error.message}';
        Get.snackbar(
          'Hata',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );

    isCategoriesLoading.value = false;
  }

  /// Kategori seçimi
  void selectCategory(int id, String name) {
    categoryId.value = id;
    selectedCategoryName.value = name;
  }

  /// Formu submit eder
  Future<void> submitForm() async {
    if (formKey.currentState?.validate() != true) {
      return;
    }

    if (categoryId.value == null) {
      Get.snackbar(
        'Hata',
        'Lütfen bir kategori seçin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (isEditing.value) {
        // Güncelleme işlemi
        final updateModel = UpdateBudgetRequestModel(
          amount: amount.value,
        );

        final result = await _budgetRepository.updateBudget(
          budgetId.value!, // null olmayacağını biliyoruz
          updateModel,
        );

        result.when(
          success: (_) {
            Get.back(
                result:
                    true); // Önceki ekrana dön ve güncelleme olduğunu bildir
            Get.snackbar(
              'Başarılı',
              'Bütçe başarıyla güncellendi',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
          failure: (error) {
            errorMessage.value =
                'Bütçe güncellenirken hata oluştu: ${error.message}';
            Get.snackbar(
              'Hata',
              errorMessage.value,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          },
        );
      } else {
        // Yeni bütçe oluşturma
        final createModel = CreateBudgetRequestModel(
          categoryId: categoryId.value!,
          amount: amount.value,
          month: month.value,
          year: year.value,
        );

        final result = await _budgetRepository.createBudget(createModel);

        result.when(
          success: (_) {
            Get.back(
                result: true); // Önceki ekrana dön ve ekleme olduğunu bildir
            Get.snackbar(
              'Başarılı',
              'Bütçe başarıyla oluşturuldu',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
          failure: (error) {
            errorMessage.value =
                'Bütçe oluşturulurken hata oluştu: ${error.message}';
            Get.snackbar(
              'Hata',
              errorMessage.value,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          },
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Bütçeyi siler
  Future<void> deleteBudget(int budgetId) async {
    if (isLoading.value) return; // İşlem devam ediyorsa çıkış yap

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _budgetRepository.deleteBudget(budgetId);

      result.when(
        success: (_) {
          Get.back(result: true); // Önceki ekrana dön
          Get.snackbar(
            'Başarılı',
            'Bütçe başarıyla silindi',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
        },
        failure: (error) {
          errorMessage.value = 'Bütçe silinirken hata oluştu: ${error.message}';
          Get.snackbar(
            'Hata',
            errorMessage.value,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      errorMessage.value = 'Beklenmeyen bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
