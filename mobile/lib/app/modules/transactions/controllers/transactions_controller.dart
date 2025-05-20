import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/request/transaction_request_models.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';
import 'package:mobile/app/domain/models/response/category_response_model.dart';
import 'package:mobile/app/domain/models/response/transaction_response_model.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/services/base_controller_mixin.dart';
import 'package:mobile/app/modules/transactions/services/transaction_data_service.dart';
import 'package:mobile/app/modules/transactions/services/transaction_filter_service.dart';
import 'package:mobile/app/modules/transactions/services/transaction_navigation_service.dart';

/// İşlemler ekranının state'ini ve iş mantığını yöneten GetX controller.
class TransactionsController extends GetxController with BaseControllerMixin {
  // Servisler
  late final TransactionDataService _dataService;
  late final TransactionFilterService _filterService;
  late final TransactionNavigationService _navigationService;

  // Scroll Controller (sonsuz kaydırma için)
  final ScrollController scrollController = ScrollController();

  TransactionsController({
    required ITransactionRepository transactionRepository,
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
  }) {
    _dataService = TransactionDataService(transactionRepository);
    _filterService = TransactionFilterService(accountRepository, categoryRepository);
    _navigationService = TransactionNavigationService();
  }

  // --- Getters ---
  @override
  RxBool get isLoading => _dataService.isLoading;

  RxBool get isLoadingMore => _dataService.isLoadingMore;

  @override
  RxString get errorMessage => _dataService.errorMessage;

  RxList<TransactionModel> get transactionList => _dataService.transactionList;

  RxDouble get totalIncome => _dataService.totalIncome;

  RxDouble get totalExpense => _dataService.totalExpense;

  RxBool get hasMoreData => _dataService.hasMoreData;

  bool get hasActiveFilters => _filterService.hasActiveFilters;

  RxBool get isFilterLoading => _filterService.isFilterLoading;

  // Filter getters
  Rx<DateTime?> get selectedStartDate => _filterService.selectedStartDate;

  Rx<DateTime?> get selectedEndDate => _filterService.selectedEndDate;

  Rx<AccountModel?> get selectedAccount => _filterService.selectedAccount;

  Rx<CategoryModel?> get selectedCategory => _filterService.selectedCategory;

  Rx<CategoryType?> get selectedType => _filterService.selectedType;

  RxString get sortCriteria => _filterService.sortCriteria;

  Rx<String?> get selectedQuickDate => _filterService.selectedQuickDate;

  RxList<AccountModel> get filterAccounts => _filterService.filterAccounts;

  RxList<CategoryModel> get filterCategories => _filterService.filterCategories;

  @override
  void onInit() {
    super.onInit();
    _logDebug('TransactionsController onInit called');
    _initializeData();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  /// Başlangıç verilerini yükler
  Future<void> _initializeData() async {
    _logDebug('_initializeData çağırıldı');
    await loadData(
      fetchFunc: () async {
        await _filterService.loadFilterOptions();
        await _fetchTransactions();
      },
      loadingErrorMessage: "İşlemler yüklenirken bir hata oluştu.",
    );
  }

  /// İşlemleri yükler
  Future<void> _fetchTransactions() async {
    final filter = _createFilterDto();
    await _dataService.fetchTransactions(filter);
  }

  /// Daha fazla işlem yükler (sayfalama için)
  Future<void> loadMoreTransactions() async {
    final filter = _createFilterDto();
    await _dataService.loadMoreTransactions(filter);
  }

  /// Scroll olaylarını dinler ve sayfalama yapar
  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (!isLoading.value && _dataService.hasMoreData.value) {
        _logDebug('loadMoreTransactions çağrıldı');
        loadMoreTransactions();
      } else {
        _logDebug('loadMoreTransactions çağrıldı, ancak hasMoreData false');
      }
    }
  }

  /// Mevcut filtre durumuna göre DTO oluşturur
  TransactionFilterDto _createFilterDto() {
    return _filterService.createFilterDto(
      pageNumber: _dataService.currentPage.value,
      pageSize: _dataService.pageSize,
    );
  }

  /// Filtreleme seansını başlatır
  void startFiltering() {
    _filterService.startFiltering();
  }

  /// Filtreleri uygular
  Future<void> applyFilters() async {
    _filterService.applyFilters();
    await _fetchTransactions();
  }

  /// Filtreleri temizler
  Future<void> clearFilters() async {
    await _filterService.clearAndApplyFilters();
    await _fetchTransactions();
  }

  /// Filtreleme iptal edildiğinde çağrılır
  void cancelFiltering() {
    _filterService.cancelFiltering();
  }

  /// Tarih aralığı seçimi için dialog gösterir
  Future<void> selectDateRange(BuildContext context) async {
    await _filterService.selectDateRange(context);
  }

  /// Hızlı tarih filtresi uygular
  Future<void> applyQuickDateFilter(String? period) async {
    await _filterService.applyQuickDateFilter(period);
    await _fetchTransactions();
  }

  /// Özet kart için tarih aralığı seçim menüsünü gösterir
  void showQuickDateMenu(BuildContext context, Offset position) {
    _filterService.showQuickDateMenu(context, position);
  }

  /// İşlem siler
  Future<void> deleteTransaction(int transactionId) async {
    if (await _dataService.deleteTransaction(transactionId)) {
      await _fetchTransactions();
    }
  }

  /// İşlem detayına gider
  void goToTransactionDetail(TransactionModel transaction) {
    _navigationService.goToTransactionDetail(transaction);
  }

  /// İşlem ekleme sayfasına gider
  void goToAddTransaction() {
    _navigationService.goToAddTransaction()?.then((result) {
      if (result == true) {
        _fetchTransactions();
      }
    });
  }

  /// İşlem düzenleme sayfasına gider
  void goToEditTransaction(TransactionModel transaction) {
    _navigationService.goToEditTransaction(transaction)?.then((result) {
      if (result == true) {
        _fetchTransactions();
      }
    });
  }

  /// Debug modunda log basar
  void _logDebug(String message) {
    if (kDebugMode) {
      print('>>> TransactionsController: $message');
    }
  }

  /// İşlemleri yükler
  Future<void> loadTransactions() async {
    await loadData(
      fetchFunc: () => _fetchTransactions(),
      loadingErrorMessage: 'İşlemler yüklenirken bir hata oluştu',
    );
  }
}
