import 'package:get/get.dart';
import 'package:mobile/app/core/services/dialog/i_dialog_service.dart';
import 'package:mobile/app/domain/models/response/budget_response_model.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/modules/budgets/services/budgets/budget_data_service.dart';
import 'package:mobile/app/modules/budgets/services/budgets/budget_filter_service.dart';
import 'package:mobile/app/modules/budgets/services/budgets/budget_navigation_service.dart';
import 'package:mobile/app/modules/budgets/services/budgets/budget_period_service.dart';
import 'package:mobile/app/services/base_controller_mixin.dart';
import 'package:flutter/foundation.dart';

// Enum'ları budget_filter_service'ten yeniden export et
export 'package:mobile/app/modules/budgets/services/budgets/budget_filter_service.dart'
    show BudgetFilterType, BudgetSortType;

/// Bütçeler ekranının state'ini ve iş mantığını yöneten GetX controller.
class BudgetsController extends GetxController with BaseControllerMixin {
  // Servisler
  late final BudgetDataService _dataService;
  late final BudgetFilterService _filterService;
  late final BudgetPeriodService _periodService;
  late final BudgetNavigationService _navigationService;
  final _dialogService = Get.find<IDialogService>();

  // Filtrelenmiş bütçe listesi - UI bu listeyi kullanacak
  final RxList<BudgetModel> filteredBudgetList = <BudgetModel>[].obs;

  BudgetsController({required IBudgetRepository budgetRepository}) {
    _dataService = BudgetDataService(budgetRepository);
    _filterService = BudgetFilterService();
    _periodService = BudgetPeriodService();
    _navigationService = BudgetNavigationService();
  }

  // --- Reactive state getters ---

  // Bütçe listesi getters
  RxList<BudgetModel> get budgetList => _dataService.budgetList;

  // Dönem seçimi getters
  Rx<DateTime> get selectedPeriod => _periodService.selectedPeriod;

  // Filtre getters
  Rx<BudgetFilterType> get activeFilter => _filterService.activeFilter;

  Rx<BudgetSortType> get activeSortType => _filterService.activeSortType;

  RxString get searchQuery => _filterService.searchQuery;

  RxList<int> get selectedCategoryIds => _filterService.selectedCategoryIds;

  bool get hasActiveFilters => _filterService.hasActiveFilters;

  // --- Lifecycle Metotları ---

  @override
  void onInit() {
    super.onInit();
    _logDebug('BudgetsController onInit called');

    // İlk yükleme sırasında _dataService ile durum paylaşımını kur
    _syncStates();

    // Controller ilk oluşturulduğunda bütçeleri çek
    loadBudgets();

    // Filtreleme değişikliklerini dinle
    ever(activeFilter, (_) => applyFilters());
    ever(activeSortType, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
    ever(selectedCategoryIds, (_) => applyFilters());
    ever(budgetList, (_) => applyFilters());
  }

  /// DataService ile durum paylaşımını sağlar
  void _syncStates() {
    // Controller → DataService
    ever(super.isLoading, (value) => _dataService.isLoading.value = value);
    ever(super.errorMessage, (value) => _dataService.errorMessage.value = value);

    // DataService → Controller (ilk başta değerlerini al)
    super.isLoading.value = _dataService.isLoading.value;
    super.errorMessage.value = _dataService.errorMessage.value;
  }

  // --- Veri İşlemleri ---

  /// Bütçeleri yükler
  Future<void> loadBudgets() async {
    final year = selectedPeriod.value.year;
    final month = selectedPeriod.value.month;

    await loadData(
      fetchFunc: () async {
        final success = await _dataService.fetchBudgetsByPeriod(year, month);
        if (!success) {
          throw Exception(_dataService.errorMessage.value);
        }
      },
      loadingErrorMessage: 'Bütçeler yüklenirken bir hata oluştu',
      preventMultipleRequests: true,
    );
  }

  /// Tüm filtreleme ve sıralama seçeneklerini uygular
  void applyFilters() {
    final result = _filterService.applyFilters(budgetList);
    filteredBudgetList.assignAll(result);
  }

  // --- Filtreleme İşlemleri ---

  /// Aktif filtreyi değiştirir
  void changeFilter(BudgetFilterType filter) {
    _filterService.changeFilter(filter);
  }

  /// Sıralama tipini değiştirir
  void changeSortType(BudgetSortType sortType) {
    _filterService.changeSortType(sortType);
  }

  /// Arama sorgusunu günceller
  void updateSearchQuery(String query) {
    _filterService.updateSearchQuery(query);
  }

  /// Kategori filtrelemesini günceller
  void toggleCategoryFilter(int categoryId) {
    _filterService.toggleCategoryFilter(categoryId);
  }

  /// Tüm filtreleri sıfırlar
  void resetFilters() {
    _filterService.resetFilters();
  }

  // --- Dönem İşlemleri ---

  /// Önceki döneme geçer
  void goToPreviousMonth() {
    _periodService.goToPreviousMonth();
    loadBudgets();
  }

  /// Sonraki döneme geçer
  void goToNextMonth() {
    _periodService.goToNextMonth();
    loadBudgets();
  }

  /// Belirli bir döneme gider
  void goToMonth(DateTime date) {
    _periodService.changePeriod(date);
    loadBudgets();
  }

  // --- Navigasyon İşlemleri ---

  /// Bütçe ekleme sayfasına yönlendirir
  void goToAddBudget() {
    _navigationService.goToAddBudget();
  }

  /// Bütçe düzenleme sayfasına yönlendirir
  void goToEditBudget(BudgetModel budget) {
    _navigationService.goToEditBudget(budget);
  }

  /// Bütçe silme işlemini gerçekleştirir
  Future<void> deleteBudget(int budgetId) async {
    final confirm = await _dialogService.showDeleteConfirmation(
      title: 'Bütçeyi sil',
      message: 'Bu bütçeyi silmek istediğinize emin misiniz?',
    );

    if (confirm == true) {
      final success = await _dataService.deleteBudget(budgetId);

      if (success) {
        _dataService.budgetList.removeWhere((budget) => budget.id == budgetId);
      }
    }
  }

  /// Debug log için yardımcı metot
  void _logDebug(String message) {
    if (kDebugMode) {
      print('>>> BudgetsController: $message');
    }
  }
}
