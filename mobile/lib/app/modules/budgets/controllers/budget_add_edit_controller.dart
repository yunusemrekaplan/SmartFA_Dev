import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/modules/budgets/services/budget_add_edit/budget_amount_service.dart';
import 'package:mobile/app/modules/budgets/services/budget_add_edit/budget_animation_service.dart';
import 'package:mobile/app/modules/budgets/services/budget_add_edit/budget_category_service.dart';
import 'package:mobile/app/modules/budgets/services/budget_add_edit/budget_data_service.dart';
import 'package:mobile/app/modules/budgets/services/budget_add_edit/budget_period_service.dart';
import 'package:mobile/app/modules/budgets/services/budget_add_edit/budget_state_service.dart';
import 'package:mobile/app/modules/budgets/services/budget_add_edit/budget_validation_service.dart';
import 'package:mobile/app/utils/snackbar_helper.dart';

class BudgetAddEditController extends GetxController {
  // Bağımlılık Enjeksiyonu (DIP prensibi)
  final IBudgetRepository _budgetRepository;
  final ICategoryRepository _categoryRepository;

  // Servisler (SRP prensibi ile ayrılmış sorumluluklar)
  late final BudgetValidationService _validationService;
  late final BudgetCategoryService _categoryService;
  late final BudgetAmountService _amountService;
  late final BudgetPeriodService _periodService;
  late final BudgetAnimationService _animationService;
  late final BudgetStateService _stateService;
  late final BudgetAddEditDataService _dataService;

  BudgetAddEditController(this._budgetRepository, this._categoryRepository) {
    _validationService = BudgetValidationService();
    _categoryService = BudgetCategoryService(_categoryRepository);
    _amountService = BudgetAmountService();
    _periodService = BudgetPeriodService();
    _animationService = BudgetAnimationService();
    _stateService = BudgetStateService();
    _dataService = BudgetAddEditDataService(_budgetRepository);
  }

  // UI Convenience Getters (delegasyon)
  GlobalKey<FormState> get formKey => _stateService.formKey;

  RxBool get isLoading => _dataService.isLoading;

  RxBool get isEditing => _stateService.isEditing;

  RxnInt get budgetId => _stateService.budgetId;

  RxString get errorMessage => _dataService.errorMessage;

  RxString get successMessage => _dataService.successMessage;

  RxBool get showCategoryError => _validationService.showCategoryError;

  RxList<CategoryModel> get categories => _categoryService.categories;

  RxBool get isCategoriesLoading => _categoryService.isCategoriesLoading;

  RxnInt get categoryId => _categoryService.selectedCategoryId;

  RxString get selectedCategoryName => _categoryService.selectedCategoryName;

  RxString get selectedCategoryIcon => _categoryService.selectedCategoryIcon;

  RxDouble get amount => _amountService.amount;

  RxInt get month => _periodService.month;

  RxInt get year => _periodService.year;

  RxBool get isFormAnimating => _animationService.isFormAnimating;

  RxBool get isCategorySelectedAnimating =>
      _animationService.isCategorySelectedAnimating;

  RxBool get isAmountEnteredAnimating =>
      _animationService.isAmountEnteredAnimating;

  @override
  void onInit() {
    super.onInit();

    // Kategorileri yükle
    fetchCategories();

    // Düzenleme modu kontrolü
    _initializeEditMode();

    // Reaktif state'i başlat
    _setupReactiveState();
  }

  /// Düzenleme modunu başlat
  void _initializeEditMode() {
    final BudgetModel? budget = Get.arguments as BudgetModel?;
    if (budget != null) {
      // Düzenleme modu
      _stateService.setupEditMode(budget.id);
      _categoryService.setupCategoryForEdit(
          budget.categoryId, budget.categoryName);
      _amountService.setAmount(budget.amount);
      _periodService.setupPeriod(budget.month, budget.year);
    }
  }

  /// Reaktif state'i ayarla
  void _setupReactiveState() {
    // Kategori değişikliklerini izle
    ever(_categoryService.selectedCategoryId, (_) {
      if (_categoryService.selectedCategoryId.value != null) {
        _animationService.triggerCategoryAnimation();
        _validationService.showCategoryError.value = false;
      }
    });

    // Tutar değişikliklerini izle
    ever(_amountService.amount, (_) {
      if (_amountService.amount.value > 0) {
        _animationService.triggerAmountAnimation();
      }
    });
  }

  /// Kategori listesini yükler
  Future<void> fetchCategories() async {
    final success = await _categoryService.fetchCategories();

    if (!success) {
      SnackbarHelper.showError(
          message: _categoryService.categoryErrorMessage.value);
    }
  }

  /// Kategori seçimi
  void selectCategory(int id, String name) {
    _categoryService.selectCategory(id, name);
  }

  /// Formu submit eder
  Future<void> submitForm() async {
    // Kategoriyi doğrula
    if (!_validationService
        .validateCategory(_categoryService.selectedCategoryId.value)) {
      SnackbarHelper.showError(message: 'Lütfen bir kategori seçin');
      return;
    }

    // Form doğrulaması
    if (!_stateService.validateForm()) {
      return;
    }

    try {
      if (_stateService.isEditMode()) {
        await _updateBudget();
      } else {
        await _createBudget();
        clearForm();
      }
    } finally {
      // İşlem durumu serviste yönetiliyor
    }
  }

  /// Bütçeyi günceller
  Future<void> _updateBudget() async {
    final success = await _dataService.updateBudget(
      budgetId: _stateService.getBudgetId()!,
      amount: _amountService.getAmount(),
    );

    if (success) {
      Get.back(result: true); // Önceki ekrana dön ve güncelleme olduğunu bildir
    }
  }

  /// Yeni bütçe oluşturur
  Future<void> _createBudget() async {
    final success = await _dataService.createBudget(
      categoryId: _categoryService.getCategoryId()!,
      amount: _amountService.getAmount(),
      month: _periodService.month.value,
      year: _periodService.year.value,
    );

    if (success) {
      Get.back(result: true); // Önceki ekrana dön ve ekleme olduğunu bildir
    }
  }

  /// Formu temizler
  void clearForm() {
    _categoryService.selectCategory(0, '');
    _amountService.setAmount(0.0);
    _periodService.setupPeriod(DateTime.now().month, DateTime.now().year);
    formKey.currentState?.reset();
  }

  /// Bütçeyi siler
  Future<void> deleteBudget(int budgetId) async {
    await _dataService.deleteBudget(budgetId);

    Get.back(result: true);
  }
}
