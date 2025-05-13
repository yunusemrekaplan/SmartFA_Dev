import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/modules/budgets/services/budgets/budget_data_service.dart';
import 'package:mobile/app/modules/budgets/services/budgets/budget_filter_service.dart';
import 'package:mobile/app/modules/budgets/services/budgets/budget_navigation_service.dart';
import 'package:mobile/app/modules/budgets/services/budgets/budget_period_service.dart';

// Enum'ları budget_filter_service'ten yeniden export et
export 'package:mobile/app/modules/budgets/services/budgets/budget_filter_service.dart'
    show BudgetFilterType, BudgetSortType;

/// Bütçeler ekranının state'ini ve iş mantığını yöneten GetX controller.
class BudgetsController extends GetxController {
  // Servisler
  late final BudgetDataService _dataService;
  late final BudgetFilterService _filterService;
  late final BudgetPeriodService _periodService;
  late final BudgetNavigationService _navigationService;

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

  RxBool get isLoading => _dataService.isLoading;

  RxString get errorMessage => _dataService.errorMessage;

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
    print('>>> BudgetsController onInit called');
    // Controller ilk oluşturulduğunda bütçeleri çek
    fetchBudgets();

    // Filtreleme değişikliklerini dinle
    ever(activeFilter, (_) => applyFilters());
    ever(activeSortType, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
    ever(selectedCategoryIds, (_) => applyFilters());
    ever(budgetList, (_) => applyFilters());
  }

  // --- Veri İşlemleri ---

  /// Kullanıcının seçili dönemdeki bütçelerini API'den çeker ve state'i günceller.
  Future<void> fetchBudgets() async {
    final year = selectedPeriod.value.year;
    final month = selectedPeriod.value.month;
    await _dataService.fetchBudgetsByPeriod(year, month);
  }

  /// Verileri manuel olarak yenilemek için metot (Pull-to-refresh vb.).
  Future<void> refreshBudgets() async {
    await fetchBudgets();
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

  /// Dönemi değiştir ve bütçeleri yeniden yükle
  void changePeriod(DateTime newPeriod) {
    _periodService.changePeriod(newPeriod);
    fetchBudgets();
  }

  /// Sonraki aya geç
  void goToNextMonth() {
    _periodService.goToNextMonth();
    fetchBudgets();
  }

  /// Önceki aya geç
  void goToPreviousMonth() {
    _periodService.goToPreviousMonth();
    fetchBudgets();
  }

  /// Bütçe formatı
  String formatMonth(DateTime date) {
    return _periodService.formatMonthName(date);
  }

  // --- Bütçe İşlemleri ---

  /// Belirli bir bütçeyi siler.
  Future<void> deleteBudget(int budgetId) async {
    await _dataService.deleteBudget(budgetId);
  }

  // --- Navigasyon İşlemleri ---

  /// Yeni bütçe ekleme ekranına yönlendirir.
  void goToAddBudget() {
    _navigationService.goToAddBudget()?.then((result) {
      if (result == true) {
        refreshBudgets();
      }
    });
  }

  /// Bütçe düzenleme ekranına yönlendirir.
  void goToEditBudget(BudgetModel budget) {
    _navigationService.goToEditBudget(budget)?.then((result) {
      if (result == true) {
        refreshBudgets();
      }
    });
  }
}
