import 'package:get/get.dart';
import 'package:mobile/app/domain/models/response/budget_response_model.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';
import 'package:mobile/app/utils/snackbar_helper.dart';

/// Bütçe verilerini yükleme ve yönetme işlemlerini gerçekleştiren servis sınıfı
class BudgetDataService {
  final IBudgetRepository _budgetRepository;
  final ErrorHandler _errorHandler = ErrorHandler();

  // Yüklenme durumu
  final RxBool isLoading = false.obs;

  // Hata durumu
  final RxString errorMessage = ''.obs;

  // Bütçe Listesi
  final RxList<BudgetModel> budgetList = <BudgetModel>[].obs;

  BudgetDataService(this._budgetRepository);

  /// Kullanıcının seçili dönemdeki bütçelerini API'den çeker ve state'i günceller.
  Future<bool> fetchBudgetsByPeriod(int year, int month) async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Hata mesajını temizle

      final result =
          await _budgetRepository.getUserBudgetsByPeriod(year, month);

      return result.when(
        success: (budgets) {
          // Başarılı: Bütçe listesini güncelle
          budgetList.assignAll(budgets);
          print('>>> Budgets fetched successfully: ${budgets.length} budgets.');
          return true;
        },
        failure: (error) {
          // Başarısız: Hata mesajını state'e ata
          print('>>> Failed to fetch budgets: ${error.message}');
          errorMessage.value = error.message;
          return false;
        },
      );
    } catch (e) {
      print('>>> Unexpected error while fetching budgets: $e');
      errorMessage.value = 'Beklenmeyen bir hata oluştu';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Belirli bir bütçeyi siler.
  Future<bool> deleteBudget(int budgetId) async {
    isLoading.value = true; // Silme işlemi sırasında indicator gösterilebilir
    errorMessage.value = '';

    try {
      final result = await _budgetRepository.deleteBudget(budgetId);

      return result.when(
        success: (_) {
          // Başarılı: Listeden bütçeyi kaldır ve başarı mesajı göster
          budgetList.removeWhere((budget) => budget.id == budgetId);
          print('>>> Budget deleted successfully: ID $budgetId');

          SnackbarHelper.showSuccess(
              message: 'Bütçe başarıyla silindi.', title: 'Başarılı');
          return true;
        },
        failure: (error) {
          // Başarısız: Hata mesajını göster
          print('>>> Failed to delete budget: ${error.message}');

          // ErrorHandler ile hata yönetimi
          _errorHandler.handleError(
            error,
            message: error.message,
            customTitle: 'Bütçe Silinemedi',
          );

          return false;
        },
      );
    } on UnexpectedException catch (e) {
      print('>>> Delete budget unexpected error: $e');

      // ErrorHandler ile beklenmeyen hata yönetimi
      _errorHandler.handleError(
        e,
        message: 'Bütçe silinirken beklenmedik bir hata oluştu.',
        customTitle: 'Bütçe Silinemedi',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
