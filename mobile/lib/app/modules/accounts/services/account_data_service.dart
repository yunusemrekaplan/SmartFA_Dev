import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';
import 'package:mobile/app/utils/snackbar_helper.dart';

/// Hesap verilerini yönetmekten sorumlu servis
/// SRP (Single Responsibility Principle) - Hesap verilerinin yönetimi tek bir sınıfta toplanır
class AccountDataService {
  final IAccountRepository _accountRepository;
  final ErrorHandler _errorHandler = ErrorHandler();

  // Observable state
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<AccountModel> accountList = <AccountModel>[].obs;

  AccountDataService(this._accountRepository);

  /// Kullanıcının hesaplarını API'den çeker ve state'i günceller
  Future<bool> fetchAccounts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _accountRepository.getUserAccounts();

      return result.when(
        success: (accounts) {
          accountList.assignAll(accounts);
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          _errorHandler.handleError(
            error,
            message: error.message,
            customTitle: 'Hesaplar Yüklenemedi',
          );
          return false;
        },
      );
    } on UnexpectedException catch (e) {
      errorMessage.value = 'Hesaplar yüklenirken beklenmedik bir hata oluştu.';
      _errorHandler.handleError(
        e,
        message: errorMessage.value,
        customTitle: 'Hesaplar Yüklenemedi',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Belirli bir hesabı siler
  Future<bool> deleteAccount(int accountId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _accountRepository.deleteAccount(accountId);

      return result.when(
        success: (_) {
          accountList.removeWhere((account) => account.id == accountId);
          SnackbarHelper.showSuccess(
            message: 'Hesap başarıyla silindi.',
            title: 'Başarılı',
          );
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          _errorHandler.handleError(
            error,
            message: error.message,
            customTitle: 'Hesap Silinemedi',
          );
          return false;
        },
      );
    } on UnexpectedException catch (e) {
      errorMessage.value = 'Hesap silinirken beklenmedik bir hata oluştu.';
      _errorHandler.handleError(
        e,
        message: errorMessage.value,
        customTitle: 'Hesap Silinemedi',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Hesapların toplam bakiyesini hesaplar
  double calculateTotalBalance() {
    return accountList.fold<double>(0, (sum, account) => sum + account.currentBalance);
  }
}
