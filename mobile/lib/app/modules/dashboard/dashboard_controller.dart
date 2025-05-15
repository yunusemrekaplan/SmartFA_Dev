import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';
import 'package:mobile/app/data/network/exceptions.dart';
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

  // Getter'lar - UI'ın servis verilerine erişimi için

  // Dashboard Durumu
  RxBool get isLoading => _stateManager.isLoading;
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
    await loadData(
      fetchFunc: _fetchAllDashboardData,
      loadingErrorMessage: 'Dashboard verileri yüklenirken bir hata oluştu',
    );
  }

  /// Verileri yeniler - Pull-to-refresh için
  Future<void> refreshDashboardData() async {
    return await refreshData(
      fetchFunc: _fetchAllDashboardData,
      refreshErrorMessage: 'Dashboard verileri yenilenirken bir hata oluştu',
    );
  }

  /// Yükleme durumunu sıfırlar - Token yenileme sonrası kullanılır
  @override
  void resetLoadingState() {
    super.resetLoadingState(); // Mixin'in metodu
    // StateManager'ı da bilgilendir (UI için gerekli)
    _stateManager.setLoadingState(false);
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

    _financialService.processTransactions(
        results[1] as Result<List<TransactionModel>, AppException>,
        _stateManager.handleError);

    _budgetService.processBudgets(
        results[2] as Result<List<BudgetModel>, AppException>,
        _stateManager.handleError);

    _financialService.processIncomeExpense(
        results[3] as Result<Map<String, double>, AppException>,
        _stateManager.handleError);
  }
}
