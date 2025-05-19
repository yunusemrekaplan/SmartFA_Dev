import 'package:get/get.dart';
import 'package:mobile/app/domain/models/response/budget_response_model.dart';
import 'package:mobile/app/domain/models/response/transaction_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/modules/dashboard/services/budget_summary_service.dart';
import 'package:mobile/app/modules/dashboard/services/dashboard_state_manager.dart';
import 'package:mobile/app/modules/dashboard/services/dashboard_summary_service.dart';
import 'package:mobile/app/modules/dashboard/services/financial_overview_service.dart';
import 'package:mobile/app/services/base_controller_mixin.dart';
import 'package:mobile/app/utils/result.dart';

/// Dashboard ekranının koordinatörü.
/// Servisleri yöneterek daha ince bir yapıya sahip.
class DashboardController extends GetxController
    with RefreshableControllerMixin {
  // Servisler - Sorumluluklar farklı servislere dağıtıldı
  final DashboardSummaryService _summaryService;
  final FinancialOverviewService _financialService;
  final BudgetSummaryService _budgetService;
  final DashboardStateManager _stateManager;

  // Yenileme kontrolü için değişkenler
  final RxBool _isRefreshing = false.obs;
  DateTime? _lastRefreshTime;
  static const int _minimumRefreshInterval = 5; // saniye

  // Getter'lar - UI'ın servis verilerine erişimi için

  // Dashboard Durumu
  @override
  RxBool get isLoading => _stateManager.isLoading;
  @override
  RxString get errorMessage => _stateManager.errorMessage;

  // Hesap Bilgileri
  RxDouble get totalBalance => _summaryService.totalBalance;
  RxInt get accountCount => _summaryService.accountCount;

  // Finansal Genel Bakış
  RxDouble get totalIncome => _financialService.totalIncome;
  RxDouble get totalExpense => _financialService.totalExpense;
  RxList<TransactionModel> get recentTransactions =>
      _financialService.recentTransactions;

  // Bütçe Bilgileri
  RxList<BudgetModel> get budgetSummaries => _budgetService.budgetSummaries;
  RxBool get hasOverspentBudgets => _budgetService.hasOverspentBudgets;

  // Constructor - Servisler enjekte edilir
  DashboardController({
    required IAccountRepository accountRepository,
    required ITransactionRepository transactionRepository,
    required IBudgetRepository budgetRepository,
    ErrorHandler? errorHandler,
  })  : _summaryService = DashboardSummaryService(
          accountRepository: accountRepository,
        ),
        _financialService = FinancialOverviewService(
          transactionRepository: transactionRepository,
        ),
        _budgetService = BudgetSummaryService(
          budgetRepository: budgetRepository,
        ),
        _stateManager = DashboardStateManager(
          errorHandler: errorHandler ?? ErrorHandler(),
        );

  /// İki-yönlü bağlama - Mixin'deki state'i StateManager ile senkronize tut
  @override
  void onInit() {
    super.onInit();

    // İsLoading durumunu güncellemek için mixin'den StateManager'a
    ever(super.isLoading, (value) {
      _stateManager.setLoadingState(value);
    });

    // Hata mesajını güncellemek için mixin'den StateManager'a
    ever(super.errorMessage, (value) {
      _stateManager.errorMessage.value = value;
    });

    // StateManager'dan mixin'e güncellemeler için (çift yönlü bağlama)
    ever(_stateManager.isLoading, (value) {
      super.isLoading.value = value;
    });

    ever(_stateManager.errorMessage, (value) {
      super.errorMessage.value = value;
    });

    // İlk verileri yükle
    loadDashboardData();
  }

  // PUBLIC API - Controller'ın dışarıya açtığı metotlar

  /// Dashboard verilerini yükler - Tüm servislerin verilerini toplar
  Future<void> loadDashboardData() async {
    if (_shouldPreventRefresh()) {
      print(
          '>>> DashboardController: Preventing refresh due to recent update or ongoing refresh');
      return;
    }

    _isRefreshing.value = true;
    _lastRefreshTime = DateTime.now();

    try {
      await loadData(
        fetchFunc: _fetchAllDashboardData,
        loadingErrorMessage: 'Dashboard verileri yüklenirken bir hata oluştu',
        preventMultipleRequests: true,
      );
    } finally {
      _isRefreshing.value = false;
    }
  }

  /// Verileri yeniler - Pull-to-refresh için
  Future<void> refreshDashboardData() async {
    if (_shouldPreventRefresh()) {
      print(
          '>>> DashboardController: Preventing refresh due to recent update or ongoing refresh');
      return;
    }

    _isRefreshing.value = true;
    _lastRefreshTime = DateTime.now();

    try {
      return await refreshData(
        fetchFunc: _fetchAllDashboardData,
        refreshErrorMessage: 'Dashboard verileri yenilenirken bir hata oluştu',
      );
    } finally {
      _isRefreshing.value = false;
    }
  }

  /// Yenileme yapılıp yapılmayacağını kontrol eder
  bool _shouldPreventRefresh() {
    if (_isRefreshing.value) {
      return true;
    }

    if (_lastRefreshTime != null) {
      final difference = DateTime.now().difference(_lastRefreshTime!);
      if (difference.inSeconds < _minimumRefreshInterval) {
        return true;
      }
    }

    return false;
  }

  /// Yükleme durumunu sıfırlar - Token yenileme sonrası kullanılır
  @override
  void resetLoadingState() {
    super.resetLoadingState(); // Mixin'in metodu
    // StateManager'ı da bilgilendir (UI için gerekli)
    _stateManager.setLoadingState(false);
    _isRefreshing.value = false;
  }

  /// Hesaplar sayfasına yönlendirir
  void navigateToAccounts() {
    _stateManager.navigateToAccounts();
  }

  /// Bütçeler sayfasına yönlendirir
  void navigateToBudgets() {
    _stateManager.navigateToBudgets();
  }

  /// İşlemler sayfasına yönlendirir
  void navigateToTransactions() {
    _stateManager.navigateToTransactions();
  }

  /// Finansal analiz sayfasına yönlendirir
  void navigateToAnalysis() {
    _stateManager.navigateToAnalysis();
  }

  // PRIVATE API - İç yardımcı metotlar

  /// Tüm dashboard verilerini paralel olarak çeker
  Future<void> _fetchAllDashboardData() async {
    final results = await Future.wait<dynamic>([
      _summaryService.fetchAccountSummary(),
      _financialService.fetchRecentTransactions(),
      _budgetService.fetchBudgetSummaries(),
      _financialService.fetchMonthlyIncomeExpense(),
    ]);

    // Sonuçları ilgili servislere işletiyoruz
    _summaryService.processAccountDetails(
        results[0] as Result<double, AppException>, _stateManager.handleError);

    // Boş veri durumunu normal karşıla, hata olarak işleme
    _financialService.processTransactions(
        results[1] as Result<List<TransactionModel>, AppException>,
        (error, title, retry) {
      if (error.message.contains('No data found')) {
        // Boş veri durumunu sessizce kabul et
        _financialService.recentTransactions.clear();
      } else {
        _stateManager.handleError(error, title, retry);
      }
    });

    // Boş bütçe durumunu normal karşıla
    _budgetService
        .processBudgets(results[2] as Result<List<BudgetModel>, AppException>,
            (error, title, retry) {
      if (error.message.contains('No data found')) {
        // Boş bütçe durumunu sessizce kabul et
        _budgetService.budgetSummaries.clear();
      } else {
        _stateManager.handleError(error, title, retry);
      }
    });

    _financialService.processIncomeExpense(
        results[3] as Result<Map<String, double>, AppException>,
        _stateManager.handleError);
  }
}
