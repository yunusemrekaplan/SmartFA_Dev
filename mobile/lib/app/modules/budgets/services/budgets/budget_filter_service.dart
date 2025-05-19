import 'package:get/get.dart';
import 'package:mobile/app/domain/models/response/budget_response_model.dart';

/// Filtreleme seçenekleri için enum
enum BudgetFilterType {
  all, // Tüm bütçeler
  overLimit, // Limit aşılmış bütçeler
  nearLimit, // Limite yaklaşan bütçeler
  underBudget, // Normal harcama olan bütçeler
}

/// Sıralama seçenekleri için enum
enum BudgetSortType {
  categoryAZ, // Kategori adına göre A-Z
  categoryZA, // Kategori adına göre Z-A
  amountHighToLow, // Toplam bütçe miktarı yüksekten düşüğe
  amountLowToHigh, // Toplam bütçe miktarı düşükten yükseğe
  spentHighToLow, // Harcanan miktar yüksekten düşüğe
  spentLowToHigh, // Harcanan miktar düşükten yükseğe
  remainingHighToLow, // Kalan miktar yüksekten düşüğe
  remainingLowToHigh, // Kalan miktar düşükten yükseğe
}

/// Bütçe filtreleme ve sıralama işlemlerini yönetir.
class BudgetFilterService {
  // Filtreleme seçenekleri
  final Rx<BudgetFilterType> activeFilter = BudgetFilterType.all.obs;

  // Sıralama seçeneği
  final Rx<BudgetSortType> activeSortType = BudgetSortType.categoryAZ.obs;

  // Arama metni
  final RxString searchQuery = ''.obs;

  // Kategori ID'sine göre filtreleme (çoklu seçim yapılabilir)
  final RxList<int> selectedCategoryIds = <int>[].obs;

  /// Tüm filtreleri uygulayıp filtrelenmiş listeyi döndürür
  List<BudgetModel> applyFilters(List<BudgetModel> budgetList) {
    if (budgetList.isEmpty) {
      return [];
    }

    // İlk filtrelemeyi yap
    List<BudgetModel> result = List.from(budgetList);

    // Durum filtresi uygula
    if (activeFilter.value != BudgetFilterType.all) {
      result = result.where((budget) {
        final double spentPercentage =
            budget.amount > 0 ? budget.spentAmount / budget.amount : 0;

        switch (activeFilter.value) {
          case BudgetFilterType.overLimit:
            return spentPercentage >= 1.0;
          case BudgetFilterType.nearLimit:
            return spentPercentage >= 0.85 && spentPercentage < 1.0;
          case BudgetFilterType.underBudget:
            return spentPercentage < 0.85;
          default:
            return true;
        }
      }).toList();
    }

    // Kategori filtresi uygula
    if (selectedCategoryIds.isNotEmpty) {
      result = result
          .where((budget) => selectedCategoryIds.contains(budget.categoryId))
          .toList();
    }

    // Arama filtresi uygula
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where((budget) => budget.categoryName.toLowerCase().contains(query))
          .toList();
    }

    // Sıralama uygula
    result = _applySorting(result);

    return result;
  }

  /// Verilen liste üzerinde sıralama uygular
  List<BudgetModel> _applySorting(List<BudgetModel> budgets) {
    switch (activeSortType.value) {
      case BudgetSortType.categoryAZ:
        budgets.sort((a, b) => a.categoryName.compareTo(b.categoryName));
        break;
      case BudgetSortType.categoryZA:
        budgets.sort((a, b) => b.categoryName.compareTo(a.categoryName));
        break;
      case BudgetSortType.amountHighToLow:
        budgets.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case BudgetSortType.amountLowToHigh:
        budgets.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case BudgetSortType.spentHighToLow:
        budgets.sort((a, b) => b.spentAmount.compareTo(a.spentAmount));
        break;
      case BudgetSortType.spentLowToHigh:
        budgets.sort((a, b) => a.spentAmount.compareTo(b.spentAmount));
        break;
      case BudgetSortType.remainingHighToLow:
        budgets.sort((a, b) => b.remainingAmount.compareTo(a.remainingAmount));
        break;
      case BudgetSortType.remainingLowToHigh:
        budgets.sort((a, b) => a.remainingAmount.compareTo(b.remainingAmount));
        break;
    }
    return budgets;
  }

  /// Aktif filtreyi değiştirir
  void changeFilter(BudgetFilterType filter) {
    activeFilter.value = filter;
  }

  /// Sıralama tipini değiştirir
  void changeSortType(BudgetSortType sortType) {
    activeSortType.value = sortType;
  }

  /// Arama sorgusunu günceller
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Kategori filtrelemesini günceller
  void toggleCategoryFilter(int categoryId) {
    if (selectedCategoryIds.contains(categoryId)) {
      selectedCategoryIds.remove(categoryId);
    } else {
      selectedCategoryIds.add(categoryId);
    }
  }

  /// Tüm filtreleri sıfırlar
  void resetFilters() {
    activeFilter.value = BudgetFilterType.all;
    activeSortType.value = BudgetSortType.categoryAZ;
    searchQuery.value = '';
    selectedCategoryIds.clear();
  }

  /// Filtrelerin aktif olup olmadığını kontrol eder
  bool get hasActiveFilters {
    return activeFilter.value != BudgetFilterType.all ||
        selectedCategoryIds.isNotEmpty ||
        searchQuery.value.isNotEmpty;
  }
}
