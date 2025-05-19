import 'package:get/get.dart';
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
class BudgetsController extends GetxController with RefreshableControllerMixin {
  // Servisler
  late final BudgetDataService _dataService;
  late final BudgetFilterService _filterService;
  late final BudgetPeriodService _periodService;
  late final BudgetNavigationService _navigationService;

  // Filtrelenmiş bütçe listesi - UI bu listeyi kullanacak
  final RxList<BudgetModel> filteredBudgetList = <BudgetModel>[].obs;

  // Çift istek kontrolü için bir zaman damgası
  DateTime? _lastFetchTimestamp;

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
    fetchBudgets(isInitialLoad: true);

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
    ever(
        super.errorMessage, (value) => _dataService.errorMessage.value = value);

    // DataService → Controller (ilk başta değerlerini al)
    super.isLoading.value = _dataService.isLoading.value;
    super.errorMessage.value = _dataService.errorMessage.value;
  }

  // --- Veri İşlemleri ---

  /// Kullanıcının seçili dönemdeki bütçelerini API'den çeker ve state'i günceller.
  Future<void> fetchBudgets(
      {bool isInitialLoad = false, bool force = false}) async {
    // İşlem başlatmadan önce debug log ekleyelim
    _logDebug(
        'fetchBudgets çağırıldı: isInitialLoad=$isInitialLoad, force=$force, '
        'current isLoading=${super.isLoading.value}');

    // Son işlem çağrısı ile şu anki çağrı arasındaki farkı kontrol et
    // Çok kısa süre içinde gelen çağrıları engelle (300ms)
    if (_lastFetchTimestamp != null) {
      final difference = DateTime.now().difference(_lastFetchTimestamp!);
      if (difference.inMilliseconds < 300 && !force) {
        _logDebug(
            'Son istekten bu yana çok kısa süre geçti (${difference.inMilliseconds}ms). İstek engellendi.');
        return;
      }
    }

    // Zaman damgasını güncelle
    _lastFetchTimestamp = DateTime.now();

    // Halihazırda yükleme yapılıyorsa ve zorlanmıyorsa, çık
    if (super.isLoading.value && !force) {
      _logDebug('Bütçeler zaten yükleniyor, yenileme iptal edildi.');
      return;
    }

    // Force modunda ise önce yükleme durumunu sıfırla
    if (force && super.isLoading.value) {
      _logDebug('Zorla yenileme: Yükleme durumu sıfırlanıyor');
      resetLoadingState();
      // Kısa bir gecikme ekle
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final year = selectedPeriod.value.year;
    final month = selectedPeriod.value.month;

    // İş mantığını yeni metoda taşıyalım
    if (isInitialLoad) {
      // Halihazırda token yenileme süreci nedeniyle çağrı yapılıp yapılmadığını
      // kontrol etmek için bir flag ekleyelim
      bool requestStarted = false;

      await loadData(
        fetchFunc: () async {
          // Eğer bu istek zaten başlatıldıysa, ikinci çağrıyı engelle
          if (requestStarted) {
            _logDebug('Duplicate request detected. Skipping...');
            return;
          }
          requestStarted = true;

          // Veri çağırma işini BudgetDataService aracılığıyla yap
          await _dataService.fetchBudgetsByPeriod(year, month);
        },
        loadingErrorMessage: 'Bütçeler yüklenirken bir hata oluştu',
        preventMultipleRequests: !force,
      );
    } else {
      // Yenileme için loadData değil refreshData kullanılmalı
      await refreshData(
        fetchFunc: () => _dataService.fetchBudgetsByPeriod(year, month),
        refreshErrorMessage: 'Bütçeler yenilenirken bir hata oluştu',
      );
    }

    _logDebug('fetchBudgets tamamlandı');
  }

  /// Verileri manuel olarak yenilemek için metot (Pull-to-refresh vb.).
  Future<void> refreshBudgets({bool force = false}) async {
    await fetchBudgets(isInitialLoad: false, force: force);
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
    fetchBudgets(isInitialLoad: true);
  }

  /// Sonraki aya geç
  void goToNextMonth() {
    _periodService.goToNextMonth();
    fetchBudgets(isInitialLoad: true);
  }

  /// Önceki aya geç
  void goToPreviousMonth() {
    _periodService.goToPreviousMonth();
    fetchBudgets(isInitialLoad: true);
  }

  /// Bütçe formatı
  String formatMonth(DateTime date) {
    return _periodService.formatMonthName(date);
  }

  // --- Bütçe İşlemleri ---

  /// Belirli bir bütçeyi siler.
  Future<void> deleteBudget(int budgetId) async {
    await loadData(
      fetchFunc: () => _dataService.deleteBudget(budgetId),
      loadingErrorMessage: 'Bütçe silinirken bir hata oluştu',
    );
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

  /// Debug log için yardımcı metot
  void _logDebug(String message) {
    if (kDebugMode) {
      print('>>> BudgetsController: $message');
    }
  }
}
