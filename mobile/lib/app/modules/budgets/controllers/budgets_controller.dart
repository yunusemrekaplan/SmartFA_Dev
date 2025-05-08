import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:mobile/app/utils/error_handler.dart';

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

/// Bütçeler ekranının state'ini ve iş mantığını yöneten GetX controller.
class BudgetsController extends GetxController {
  // Repository'yi inject et (Binding üzerinden)
  final IBudgetRepository _budgetRepository;
  final ErrorHandler _errorHandler = ErrorHandler();

  BudgetsController(this._budgetRepository);

  // --- State Değişkenleri ---

  // Yüklenme durumu
  final RxBool isLoading = true.obs; // Başlangıçta yükleniyor

  // Hata durumu
  final RxString errorMessage = ''.obs;

  // Bütçe Listesi
  final RxList<BudgetModel> budgetList = <BudgetModel>[].obs;

  // Filtre ve sıralamanın uygulandığı liste - UI bu listeyi kullanacak
  final RxList<BudgetModel> filteredBudgetList = <BudgetModel>[].obs;

  // Filtreleme için seçili dönem (ay/yıl)
  final Rx<DateTime> selectedPeriod = DateTime.now().obs;

  // Filtreleme seçenekleri
  final Rx<BudgetFilterType> activeFilter = BudgetFilterType.all.obs;

  // Sıralama seçeneği
  final Rx<BudgetSortType> activeSortType = BudgetSortType.categoryAZ.obs;

  // Filtre veya sıralama değiştiğinde kullanılacak arama metni
  final RxString searchQuery = ''.obs;

  // Kategori ID'sine göre filtreleme (çoklu seçim yapılabilir)
  final RxList<int> selectedCategoryIds = <int>[].obs;

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

  // --- Metotlar ---

  /// Kullanıcının seçili dönemdeki bütçelerini API'den çeker ve state'i günceller.
  Future<void> fetchBudgets() async {
    isLoading.value = true;
    errorMessage.value = ''; // Hata mesajını temizle

    final int year = selectedPeriod.value.year;
    final int month = selectedPeriod.value.month;

    try {
      final result = await _budgetRepository.getUserBudgetsByPeriod(year, month);

      result.when(
        success: (budgets) {
          // Başarılı: Bütçe listesini güncelle
          budgetList.assignAll(budgets);
          print('>>> Budgets fetched successfully: ${budgets.length} budgets.');
        },
        failure: (error) {
          // Başarısız: Hata mesajını state'e ata
          print('>>> Failed to fetch budgets: ${error.message}');
          errorMessage.value = error.message;

          // ErrorHandler ile hata yönetimi
          _errorHandler.handleError(
            error,
            onRetry: fetchBudgets,
            customTitle: 'Bütçeler Yüklenemedi',
          );
        },
      );
    } catch (e) {
      // Beklenmedik genel hatalar
      print('>>> Fetch budgets unexpected error: $e');
      errorMessage.value = 'Bütçeler yüklenirken beklenmedik bir hata oluştu.';

      // ErrorHandler ile beklenmeyen hata yönetimi
      _errorHandler.handleUnexpectedError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Tüm filtreleme ve sıralama seçeneklerini uygular
  void applyFilters() {
    if (budgetList.isEmpty) {
      filteredBudgetList.clear();
      return;
    }

    // İlk filtrelemeyi yap
    List<BudgetModel> result = List.from(budgetList);

    // Durum filtresi uygula
    if (activeFilter.value != BudgetFilterType.all) {
      result = result.where((budget) {
        final double spentPercentage = budget.amount > 0 ? budget.spentAmount / budget.amount : 0;

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
      result = result.where((budget) => selectedCategoryIds.contains(budget.categoryId)).toList();
    }

    // Arama filtresi uygula
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((budget) => budget.categoryName.toLowerCase().contains(query)).toList();
    }

    // Sıralama uygula
    switch (activeSortType.value) {
      case BudgetSortType.categoryAZ:
        result.sort((a, b) => a.categoryName.compareTo(b.categoryName));
        break;
      case BudgetSortType.categoryZA:
        result.sort((a, b) => b.categoryName.compareTo(a.categoryName));
        break;
      case BudgetSortType.amountHighToLow:
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case BudgetSortType.amountLowToHigh:
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case BudgetSortType.spentHighToLow:
        result.sort((a, b) => b.spentAmount.compareTo(a.spentAmount));
        break;
      case BudgetSortType.spentLowToHigh:
        result.sort((a, b) => a.spentAmount.compareTo(b.spentAmount));
        break;
      case BudgetSortType.remainingHighToLow:
        result.sort((a, b) => b.remainingAmount.compareTo(a.remainingAmount));
        break;
      case BudgetSortType.remainingLowToHigh:
        result.sort((a, b) => a.remainingAmount.compareTo(b.remainingAmount));
        break;
    }

    // Filtrelenmiş ve sıralanmış listeyi güncelle
    filteredBudgetList.assignAll(result);
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

  /// Dönemi değiştir ve bütçeleri yeniden yükle
  void changePeriod(DateTime newPeriod) {
    selectedPeriod.value = newPeriod;
    fetchBudgets();
  }

  /// Sonraki aya geç
  void goToNextMonth() {
    final DateTime currentPeriod = selectedPeriod.value;
    final DateTime nextMonth = DateTime(
      currentPeriod.year + (currentPeriod.month == 12 ? 1 : 0),
      currentPeriod.month == 12 ? 1 : currentPeriod.month + 1,
    );
    selectedPeriod.value = nextMonth;
    fetchBudgets();
  }

  /// Önceki aya geç
  void goToPreviousMonth() {
    final DateTime currentPeriod = selectedPeriod.value;
    final DateTime previousMonth = DateTime(
      currentPeriod.year - (currentPeriod.month == 1 ? 1 : 0),
      currentPeriod.month == 1 ? 12 : currentPeriod.month - 1,
    );
    selectedPeriod.value = previousMonth;
    fetchBudgets();
  }

  /// Verileri manuel olarak yenilemek için metot (Pull-to-refresh vb.).
  Future<void> refreshBudgets() async {
    await fetchBudgets();
  }

  /// Belirli bir bütçeyi siler.
  Future<void> deleteBudget(int budgetId) async {
    isLoading.value = true; // Silme işlemi sırasında indicator gösterilebilir
    errorMessage.value = '';

    try {
      final result = await _budgetRepository.deleteBudget(budgetId);

      result.when(
        success: (_) {
          // Başarılı: Listeden bütçeyi kaldır ve başarı mesajı göster
          budgetList.removeWhere((budget) => budget.id == budgetId);
          print('>>> Budget deleted successfully: ID $budgetId');

          // ErrorHandler ile başarı mesajı göster
          _errorHandler.showSuccessMessage('Bütçe başarıyla silindi.');
        },
        failure: (error) {
          // Başarısız: Hata mesajını göster
          print('>>> Failed to delete budget: ${error.message}');
          errorMessage.value = error.message;

          // ErrorHandler ile hata yönetimi
          _errorHandler.handleError(
            error,
            customTitle: 'Bütçe Silinemedi',
          );
        },
      );
    } catch (e) {
      print('>>> Delete budget unexpected error: $e');
      errorMessage.value = 'Bütçe silinirken beklenmedik bir hata oluştu.';

      // ErrorHandler ile beklenmeyen hata yönetimi
      _errorHandler.handleUnexpectedError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Yeni bütçe ekleme ekranına yönlendirir.
  void goToAddBudget() {
    Get.toNamed(AppRoutes.ADD_EDIT_BUDGET)?.then((result) {
      // Yeni bütçe eklendikten sonra bu ekrana geri dönüldüğünde
      // liste otomatik olarak güncellenebilir.
      if (result == true) {
        // Ekleme ekranı başarılı olursa true dönsün
        refreshBudgets();
      }
    });
  }

  /// Bütçe düzenleme ekranına yönlendirir.
  void goToEditBudget(BudgetModel budget) {
    Get.toNamed(AppRoutes.ADD_EDIT_BUDGET, arguments: budget)?.then((result) {
      if (result == true) {
        refreshBudgets();
      }
    });
    print('Edit budget tıklandı: ${budget.id}');
  }
}
