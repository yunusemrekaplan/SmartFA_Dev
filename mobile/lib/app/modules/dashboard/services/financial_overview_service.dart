import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/request/transaction_request_models.dart';
import 'package:mobile/app/domain/models/response/transaction_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/utils/result.dart';

/// Finansal genel bakış servis sınıfı.
/// Gelir, gider ve işlem özetlerini yönetir.
class FinancialOverviewService {
  // Repository'ler
  final ITransactionRepository _transactionRepository;

  // State değişkenleri
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxList<TransactionModel> recentTransactions = <TransactionModel>[].obs;

  // Kategori bazlı gruplandırılmış işlemler
  final RxMap<String, List<TransactionModel>> groupedTransactions =
      <String, List<TransactionModel>>{}.obs;

  // Constructor - Dependency Injection
  FinancialOverviewService({
    required ITransactionRepository transactionRepository,
  }) : _transactionRepository = transactionRepository;

  /// Son işlemleri çeker
  Future<Result<List<TransactionModel>, AppException>>
      fetchRecentTransactions() async {
    final filter = _createRecentTransactionsFilter();
    return await _transactionRepository.getUserTransactions(filter);
  }

  /// Son işlemler için filtre oluşturur
  TransactionFilterDto _createRecentTransactionsFilter() {
    // Dashboard için son 10 işlem yeterli
    return TransactionFilterDto(pageNumber: 1, pageSize: 10);
  }

  /// Aylık gelir ve giderleri çeker
  Future<Result<Map<String, double>, AppException>>
      fetchMonthlyIncomeExpense() async {
    try {
      final dateRange = _getCurrentMonthDateRange();
      final filter = _createMonthlyTransactionsFilter(dateRange);
      final result = await _transactionRepository.getUserTransactions(filter);

      return result.when(
        success: (transactions) =>
            Success(_calculateIncomeAndExpense(transactions)),
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
  TransactionFilterDto _createMonthlyTransactionsFilter(
      Map<String, DateTime> dateRange) {
    return TransactionFilterDto(
      pageSize: 100,
      startDate: dateRange['start'],
      endDate: dateRange['end'],
    );
  }

  /// İşlemlerden gelir ve gider toplamlarını hesaplar
  Map<String, double> _calculateIncomeAndExpense(
      List<TransactionModel> transactions) {
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

  /// İşlemleri kategoriye göre grupla
  Map<String, List<TransactionModel>> groupTransactionsByCategory(
      List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};

    for (final transaction in transactions) {
      final categoryName = transaction.categoryName;

      if (!grouped.containsKey(categoryName)) {
        grouped[categoryName] = [];
      }

      grouped[categoryName]!.add(transaction);
    }

    return grouped;
  }

  /// Kategori bazında toplam tutarı hesapla
  double calculateCategoryTotal(List<TransactionModel> transactions) {
    return transactions.fold(
        0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Beklenmedik bir hata oluştuğunda AppException oluşturur
  UnexpectedException _createUnexpectedException(dynamic error) {
    return UnexpectedException(
      message: 'Finansal özet alınırken beklenmedik bir hata oluştu: $error',
      code: 'FINANCIAL_OVERVIEW_ERROR',
    );
  }

  /// İşlemleri işler
  void processTransactions(Result<List<TransactionModel>, AppException> result,
      Function(AppException, String, VoidCallback) errorHandler) {
    result.when(
      success: (transactions) {
        recentTransactions.assignAll(transactions);

        // Kategori bazlı gruplandırma
        final grouped = groupTransactionsByCategory(transactions);
        groupedTransactions.assignAll(grouped);
      },
      failure: (error) => errorHandler(
          error, 'Son İşlemler Yüklenemedi', () => fetchRecentTransactions()),
    );
  }

  /// Gelir-gider bilgilerini işler
  void processIncomeExpense(Result<Map<String, double>, AppException> result,
      Function(AppException, String, VoidCallback) errorHandler) {
    result.when(
      success: (data) {
        totalIncome.value = data['income'] ?? 0;
        totalExpense.value = data['expense'] ?? 0;
      },
      failure: (error) => errorHandler(error, 'Gelir-Gider Özeti Yüklenemedi',
          () => fetchMonthlyIncomeExpense()),
    );
  }
}
