import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/utils/result.dart';

/// Bütçe özeti servis sınıfı.
/// Bütçe özetlerini ve aşım kontrolünü yönetir.
class BudgetSummaryService {
  // Repository'ler
  final IBudgetRepository _budgetRepository;

  // State değişkenleri
  final RxList<BudgetModel> budgetSummaries = <BudgetModel>[].obs;
  final RxBool hasOverspentBudgets = false.obs;

  // Constructor - Dependency Injection
  BudgetSummaryService({
    required IBudgetRepository budgetRepository,
  }) : _budgetRepository = budgetRepository;

  /// Bütçe özetlerini çeker
  Future<Result<List<BudgetModel>, AppException>> fetchBudgetSummaries() async {
    final date = DateTime.now();
    return await _budgetRepository.getUserBudgetsByPeriod(
        date.year, date.month);
  }

  /// Bütçeleri işler
  void processBudgets(Result<List<BudgetModel>, AppException> result,
      Function(AppException, String, VoidCallback) errorHandler) {
    result.when(
      success: (budgets) {
        budgetSummaries.assignAll(budgets);
        _checkForOverspentBudgets(budgets);
      },
      failure: (error) => errorHandler(
          error, 'Bütçeler Yüklenemedi', () => fetchBudgetSummaries()),
    );
  }

  /// Bütçelerde aşım olup olmadığını kontrol eder
  void _checkForOverspentBudgets(List<BudgetModel> budgets) {
    hasOverspentBudgets.value =
        budgets.any((budget) => budget.spentAmount > budget.amount);
  }

  /// Belirli bir bütçe kategorisinin harcama yüzdesini hesaplar
  double calculateSpentPercentage(BudgetModel budget) {
    if (budget.amount <= 0) return 0;
    return (budget.spentAmount / budget.amount) * 100;
  }

  /// Bütçe durumlarını getirir (güvenli, uyarı, aşım)
  String getBudgetStatus(BudgetModel budget) {
    final percentage = calculateSpentPercentage(budget);

    if (percentage >= 100) {
      return 'overspent';
    } else if (percentage >= 85) {
      return 'warning';
    } else {
      return 'safe';
    }
  }

  /// En çok harcama yapılan bütçe kategorilerini getirir
  List<BudgetModel> getTopSpendingCategories({int limit = 3}) {
    final sortedBudgets = List<BudgetModel>.from(budgetSummaries)
      ..sort((a, b) => b.spentAmount.compareTo(a.spentAmount));

    return sortedBudgets.take(limit).toList();
  }
}
