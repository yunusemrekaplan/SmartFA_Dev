import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/request/transaction_request_models.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/modules/home/home_controller.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:mobile/app/utils/error_handler.dart';
import 'package:mobile/app/utils/exceptions.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/utils/result.dart';

/// Dashboard ekranının state'ini ve iş mantığını yöneten GetX controller.
/// SOLID prensiplerine uygun şekilde refactor edildi.
class DashboardController extends GetxController {
  // Repository'ler - Dependency Inversion için interface üzerinden erişim
  final IAccountRepository _accountRepository;
  final ITransactionRepository _transactionRepository;
  final IBudgetRepository _budgetRepository;

  // Yardımcı servisler
  final ErrorHandler _errorHandler;

  // State değişkenleri
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Dashboard Verileri
  final RxDouble totalBalance = 0.0.obs;
  final RxList<TransactionModel> recentTransactions = <TransactionModel>[].obs;
  final RxList<BudgetModel> budgetSummaries = <BudgetModel>[].obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxInt accountCount = 0.obs;
  final RxBool hasOverspentBudgets = false.obs;

  // Constructor - Dependency Injection
  DashboardController({
    required IAccountRepository accountRepository,
    required ITransactionRepository transactionRepository,
    required IBudgetRepository budgetRepository,
    ErrorHandler? errorHandler,
  })  : _accountRepository = accountRepository,
        _transactionRepository = transactionRepository,
        _budgetRepository = budgetRepository,
        _errorHandler = errorHandler ?? ErrorHandler();

  // Lifecycle metotları
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // PUBLIC API - Controller'ın dışarıya açtığı metotlar

  /// Dashboard verilerini yükler
  Future<void> loadDashboardData() async {
    _setLoadingState(true);
    _clearErrorMessage();

    try {
      await _fetchAllDashboardData();
    } catch (e) {
      _handleUnexpectedError(e);
    } finally {
      _setLoadingState(false);
    }
  }

  /// Verileri yeniler - Pull-to-refresh için
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  /// Hesaplar sayfasına yönlendirir
  void navigateToAccounts() {
    try {
      Get.find<HomeController>().changeTabIndex(1);
    } catch (e) {
      _navigateByRoute(AppRoutes.ACCOUNTS);
    }
  }

  /// Bütçeler sayfasına yönlendirir
  void navigateToBudgets() {
    try {
      Get.find<HomeController>().changeTabIndex(3);
    } catch (e) {
      _navigateByRoute(AppRoutes.BUDGETS);
    }
  }

  /// İşlemler sayfasına yönlendirir
  void navigateToTransactions() {
    try {
      Get.find<HomeController>().changeTabIndex(2);
    } catch (e) {
      _navigateByRoute(AppRoutes.TRANSACTIONS);
    }
  }

  /// Finansal analiz sayfasına yönlendirir (henüz yapım aşamasında)
  void navigateToAnalysis() {
    _showFeatureInDevelopmentMessage();
  }

  // PRIVATE API - İç yardımcı metotlar

  /// Tüm dashboard verilerini paralel olarak çeker
  Future<void> _fetchAllDashboardData() async {
    final results = await Future.wait([
      _fetchAccountDetails(),
      _fetchRecentTransactions(),
      _fetchBudgetSummaries(),
      _fetchMonthlyIncomeExpense(),
    ]);

    _processAccountDetails(results[0] as Result<double, AppException>);
    _processTransactions(results[1] as Result<List<TransactionModel>, AppException>);
    _processBudgets(results[2] as Result<List<BudgetModel>, AppException>);
    _processIncomeExpense(results[3] as Result<Map<String, double>, AppException>);
  }

  /// Loading state'i değiştirir
  void _setLoadingState(bool loading) {
    isLoading.value = loading;
  }

  /// Hata mesajını temizler
  void _clearErrorMessage() {
    errorMessage.value = '';
  }

  /// Hesap detaylarını çeker (bakiye ve hesap sayısı)
  Future<Result<double, AppException>> _fetchAccountDetails() async {
    final result = await _accountRepository.getUserAccounts();
    return result.when(
      success: (accounts) {
        final balance = _calculateTotalBalance(accounts);
        _updateAccountCount(accounts.length);
        return Success(balance);
      },
      failure: (error) => Failure(error),
    );
  }

  /// Toplam bakiyeyi hesaplar
  double _calculateTotalBalance(List<dynamic> accounts) {
    return accounts.fold(0.0, (sum, account) => sum + account.currentBalance);
  }

  /// Hesap sayısını günceller
  void _updateAccountCount(int count) {
    accountCount.value = count;
  }

  /// Son işlemleri çeker
  Future<Result<List<TransactionModel>, AppException>> _fetchRecentTransactions() async {
    final filter = _createRecentTransactionsFilter();
    return await _transactionRepository.getUserTransactions(filter);
  }

  /// Son işlemler için filtre oluşturur
  TransactionFilterDto _createRecentTransactionsFilter() {
    return TransactionFilterDto(pageNumber: 1, pageSize: 5);
  }

  /// Bütçe özetlerini çeker
  Future<Result<List<BudgetModel>, AppException>> _fetchBudgetSummaries() async {
    final date = DateTime.now();
    return await _budgetRepository.getUserBudgetsByPeriod(date.year, date.month);
  }

  /// Aylık gelir ve giderleri çeker
  Future<Result<Map<String, double>, AppException>> _fetchMonthlyIncomeExpense() async {
    try {
      final dateRange = _getCurrentMonthDateRange();
      final filter = _createMonthlyTransactionsFilter(dateRange);
      final result = await _transactionRepository.getUserTransactions(filter);

      return result.when(
        success: (transactions) => Success(_calculateIncomeAndExpense(transactions)),
        failure: (error) => Failure(error),
      );
    } catch (e) {
      return Failure(_createUnexpectedException(e));
    }
  }

  /// Geçerli ayın tarih aralığını döndürür
  Map<String, DateTime> _getCurrentMonthDateRange() {
    final now = DateTime.now();
    return {
      'start': DateTime(now.year, now.month, 1),
      'end': DateTime(now.year, now.month + 1, 0),
    };
  }

  /// Aylık işlemler için filtre oluşturur
  TransactionFilterDto _createMonthlyTransactionsFilter(Map<String, DateTime> dateRange) {
    return TransactionFilterDto(
      pageSize: 100,
      startDate: dateRange['start'],
      endDate: dateRange['end'],
    );
  }

  /// İşlemlerden gelir ve gider toplamlarını hesaplar
  Map<String, double> _calculateIncomeAndExpense(List<TransactionModel> transactions) {
    double income = 0;
    double expense = 0;

    for (var transaction in transactions) {
      if (transaction.categoryType == CategoryType.Income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return {'income': income, 'expense': expense};
  }

  /// Beklenmedik bir hata oluştuğunda AppException oluşturur
  UnexpectedException _createUnexpectedException(dynamic error) {
    return UnexpectedException(
      message: 'Beklenmedik bir hata oluştu: $error',
      code: 'UNEXPECTED_ERROR',
    );
  }

  /// Beklenmedik hataları yakalar ve kullanıcıya gösterir
  void _handleUnexpectedError(dynamic error) {
    print('>>> DashboardController Unexpected Error: $error');
    errorMessage.value = 'Dashboard verileri yüklenirken beklenmedik bir hata oluştu.';
  }

  /// Hesap bilgilerini işler
  void _processAccountDetails(Result<double, AppException> result) {
    result.when(
      success: (balance) => totalBalance.value = balance,
      failure: (error) => _handleError(error, 'Bakiye Yüklenemedi', () => _fetchAccountDetails()),
    );
  }

  /// İşlemleri işler
  void _processTransactions(Result<List<TransactionModel>, AppException> result) {
    result.when(
      success: (transactions) => recentTransactions.assignAll(transactions),
      failure: (error) =>
          _handleError(error, 'Son İşlemler Yüklenemedi', () => _fetchRecentTransactions()),
    );
  }

  /// Bütçeleri işler
  void _processBudgets(Result<List<BudgetModel>, AppException> result) {
    result.when(
      success: (budgets) {
        budgetSummaries.assignAll(budgets);
        _checkForOverspentBudgets(budgets);
      },
      failure: (error) =>
          _handleError(error, 'Bütçeler Yüklenemedi', () => _fetchBudgetSummaries()),
    );
  }

  /// Gelir-gider bilgilerini işler
  void _processIncomeExpense(Result<Map<String, double>, AppException> result) {
    result.when(
      success: (data) {
        totalIncome.value = data['income'] ?? 0;
        totalExpense.value = data['expense'] ?? 0;
      },
      failure: (error) =>
          _handleError(error, 'Gelir-Gider Özeti Yüklenemedi', () => _fetchMonthlyIncomeExpense()),
    );
  }

  /// Hataları ErrorHandler ile işleyip hata mesajı oluşturur
  void _handleError(AppException error, String title, VoidCallback onRetry) {
    _errorHandler.handleError(
      error,
      onRetry: onRetry,
      customTitle: title,
    );
  }

  /// Bütçelerde aşım olup olmadığını kontrol eder
  void _checkForOverspentBudgets(List<BudgetModel> budgets) {
    hasOverspentBudgets.value = budgets.any((budget) => budget.spentAmount > budget.amount);
  }

  /// Belirtilen rotaya yönlendirir
  void _navigateByRoute(String route) {
    Get.toNamed(route);
  }

  /// "Yapım aşamasında" mesajı gösterir
  void _showFeatureInDevelopmentMessage() {
    Get.snackbar(
      'Yapım Aşamasında',
      'Detaylı finans analizi yakında kullanıma sunulacak!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
