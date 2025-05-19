import 'package:get/get.dart';
import 'package:mobile/app/domain/models/request/budget_request_models.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';
import 'package:mobile/app/utils/snackbar_helper.dart';

/// Bütçe ekleme ve düzenleme işlemlerindeki veri yönetimini sağlayan servis
/// SRP (Single Responsibility) prensibine uygun
class BudgetAddEditDataService {
  final IBudgetRepository _budgetRepository;
  final ErrorHandler _errorHandler = ErrorHandler();

  // İşlem durumları
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  BudgetAddEditDataService(this._budgetRepository);

  /// Yeni bütçe oluşturur
  Future<bool> createBudget(
      {required int categoryId,
      required double amount,
      required int month,
      required int year}) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final createModel = CreateBudgetRequestModel(
        categoryId: categoryId,
        amount: amount,
        month: month,
        year: year,
      );

      final result = await _budgetRepository.createBudget(createModel);

      return result.when(
        success: (_) {
          successMessage.value = 'Bütçe başarıyla oluşturuldu';
          SnackbarHelper.showSuccess(
            message: 'Bütçe başarıyla oluşturuldu.',
            title: 'Başarılı',
          );

          return true;
        },
        failure: (error) {
          _errorHandler.handleError(
            error,
            message: error.message,
            customTitle: 'Bütçe Oluşturulamadı',
          );

          return false;
        },
      );
    } on UnexpectedException catch (e) {
      _errorHandler.handleError(
        e,
        message: 'Bütçe oluşturulurken beklenmedik bir hata oluştu.',
        customTitle: 'Bütçe Oluşturulamadı',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Mevcut bütçeyi günceller
  Future<bool> updateBudget(
      {required int budgetId, required double amount}) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final updateModel = UpdateBudgetRequestModel(
        amount: amount,
      );

      final result =
          await _budgetRepository.updateBudget(budgetId, updateModel);

      return result.when(
        success: (_) {
          successMessage.value = 'Bütçe başarıyla güncellendi';
          SnackbarHelper.showSuccess(
            message: 'Bütçe başarıyla güncellendi.',
            title: 'Başarılı',
          );

          return true;
        },
        failure: (error) {
          _errorHandler.handleError(
            error,
            message: error.message,
            customTitle: 'Bütçe Güncellenemedi',
          );

          return false;
        },
      );
    } on UnexpectedException catch (e) {
      _errorHandler.handleError(
        e,
        message: 'Bütçe güncellenirken beklenmedik bir hata oluştu.',
        customTitle: 'Bütçe Güncellenemedi',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Bütçeyi siler
  Future<bool> deleteBudget(int budgetId) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final result = await _budgetRepository.deleteBudget(budgetId);

      return result.when(
        success: (_) {
          successMessage.value = 'Bütçe başarıyla silindi';
          SnackbarHelper.showSuccess(
            message: 'Bütçe başarıyla silindi.',
            title: 'Başarılı',
          );

          return true;
        },
        failure: (error) {
          _errorHandler.handleError(
            error,
            message: error.message,
            customTitle: 'Bütçe Silinemedi',
          );

          return false;
        },
      );
    } on UnexpectedException catch (e) {
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
