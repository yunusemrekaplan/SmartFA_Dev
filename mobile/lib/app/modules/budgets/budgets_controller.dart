import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Bütçeler ekranının state'ini ve iş mantığını yöneten GetX controller.
class BudgetsController extends GetxController {
  // Repository'yi inject et (Binding üzerinden)
  final IBudgetRepository _budgetRepository;

  BudgetsController(this._budgetRepository);

  // --- State Değişkenleri ---

  // Yüklenme durumu
  final RxBool isLoading = true.obs; // Başlangıçta yükleniyor

  // Hata durumu
  final RxString errorMessage = ''.obs;

  // Bütçe Listesi
  final RxList<BudgetModel> budgetList = <BudgetModel>[].obs;

  // Filtreleme için seçili dönem (ay/yıl)
  final Rx<DateTime> selectedPeriod = DateTime.now().obs;

  // --- Lifecycle Metotları ---

  @override
  void onInit() {
    super.onInit();
    print('>>> BudgetsController onInit called');
    // Controller ilk oluşturulduğunda bütçeleri çek
    fetchBudgets();
  }

  // --- Metotlar ---

  /// Kullanıcının seçili dönemdeki bütçelerini API'den çeker ve state'i günceller.
  Future<void> fetchBudgets() async {
    isLoading.value = true;
    errorMessage.value = ''; // Hata mesajını temizle

    final int year = selectedPeriod.value.year;
    final int month = selectedPeriod.value.month;

    try {
      final result =
          await _budgetRepository.getUserBudgetsByPeriod(year, month);

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
          // Kullanıcıya hata mesajı gösterilebilir (Snackbar vb.)
          // Get.snackbar('Hata', error.message);
        },
      );
    } catch (e) {
      // Beklenmedik genel hatalar
      print('>>> Fetch budgets unexpected error: $e');
      errorMessage.value = 'Bütçeler yüklenirken beklenmedik bir hata oluştu.';
    } finally {
      isLoading.value = false;
    }
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
          Get.snackbar(
            'Başarılı',
            'Bütçe başarıyla silindi.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        failure: (error) {
          // Başarısız: Hata mesajını göster
          print('>>> Failed to delete budget: ${error.message}');
          errorMessage.value = error.message;
          Get.snackbar(
            'Hata',
            'Bütçe silinirken bir sorun oluştu: ${error.message}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      print('>>> Delete budget unexpected error: $e');
      errorMessage.value = 'Bütçe silinirken beklenmedik bir hata oluştu.';
      Get.snackbar(
        'Hata',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
