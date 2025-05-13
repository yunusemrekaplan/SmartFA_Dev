import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/result.dart';

/// Dashboard ana verilerini yönetmek için servis sınıfı.
/// DashboardController'dan ayrıştırılmış veri yükleme sorumluluğu.
class DashboardSummaryService {
  // Repository'ler - Dependency Inversion için interface üzerinden erişim
  final IAccountRepository _accountRepository;

  // State değişkenleri
  final RxDouble totalBalance = 0.0.obs;
  final RxInt accountCount = 0.obs;

  // Constructor - Dependency Injection
  DashboardSummaryService({
    required IAccountRepository accountRepository,
  }) : _accountRepository = accountRepository;

  /// Hesap özetlerini çeker
  Future<Result<double, AppException>> fetchAccountSummary() async {
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

  /// Hesap bilgilerini işler
  void processAccountDetails(Result<double, AppException> result,
      Function(AppException, String, VoidCallback) errorHandler) {
    result.when(
      success: (balance) => totalBalance.value = balance,
      failure: (error) => errorHandler(
          error, 'Bakiye Yüklenemedi', () => fetchAccountSummary()),
    );
  }

  /// Beklenmedik bir hata oluştuğunda AppException oluşturur
  UnexpectedException createUnexpectedException(dynamic error) {
    return UnexpectedException(
      message: 'Hesap verileri alınırken beklenmedik bir hata oluştu: $error',
      code: 'ACCOUNT_SUMMARY_ERROR',
    );
  }
}
