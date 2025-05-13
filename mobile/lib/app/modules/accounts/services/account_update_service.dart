import 'package:get/get.dart';
import 'package:mobile/app/data/models/enums/account_type.dart';
import 'package:mobile/app/data/models/request/account_request_models.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/error_handler.dart';
import 'package:mobile/app/utils/snackbar_helper.dart';

/// Hesap ekleme, güncelleme ve silme işlemlerini yöneten servis
/// SRP (Single Responsibility Principle) - Hesap CRUD işlemleri tek bir sınıfta toplanır
class AccountUpdateService {
  final IAccountRepository _accountRepository;
  final ErrorHandler _errorHandler = ErrorHandler();

  // Observable state
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  AccountUpdateService(this._accountRepository);

  /// Yeni hesap oluşturur
  Future<bool> createAccount({
    required String name,
    required double initialBalance,
    required AccountType type,
    String currency = 'TRY',
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final accountData = CreateAccountRequestModel(
        name: name,
        initialBalance: initialBalance,
        type: type,
        currency: currency,
      );

      final result = await _accountRepository.createAccount(accountData);

      return result.when(
        success: (_) {
          SnackbarHelper.showSuccess(
            message: 'Hesap başarıyla eklendi.',
            title: 'Başarılı',
          );
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          _errorHandler.handleError(
            error,
            message: error.message,
            customTitle: 'Hesap Eklenemedi',
          );
          return false;
        },
      );
    } on UnexpectedException catch (e) {
      errorMessage.value = 'Hesap eklenirken beklenmedik bir hata oluştu.';
      _errorHandler.handleError(
        e,
        message: errorMessage.value,
        customTitle: 'Hesap Eklenemedi',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Var olan hesabı günceller
  Future<bool> updateAccount({
    required int accountId,
    required String name,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final accountData = UpdateAccountRequestModel(
        name: name,
      );

      final result = await _accountRepository.updateAccount(
        accountId,
        accountData,
      );

      return result.when(
        success: (_) {
          SnackbarHelper.showSuccess(
            message: 'Hesap başarıyla güncellendi.',
            title: 'Başarılı',
          );
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          _errorHandler.handleError(
            error,
            message: error.message,
            customTitle: 'Hesap Güncellenemedi',
          );
          return false;
        },
      );
    } on UnexpectedException catch (e) {
      errorMessage.value = 'Hesap güncellenirken beklenmedik bir hata oluştu.';
      _errorHandler.handleError(
        e,
        message: errorMessage.value,
        customTitle: 'Hesap Güncellenemedi',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Hesabı siler
  Future<bool> deleteAccount(int accountId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _accountRepository.deleteAccount(accountId);

      return result.when(
        success: (_) {
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
}
