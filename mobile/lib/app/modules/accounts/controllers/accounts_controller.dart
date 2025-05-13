import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:mobile/app/utils/error_handler.dart';
import 'package:mobile/app/data/network/exceptions.dart';

/// Hesaplar ekranının state'ini ve iş mantığını yöneten GetX controller.
class AccountsController extends GetxController {
  // Repository'yi inject et (Binding üzerinden)
  final IAccountRepository _accountRepository;
  final ErrorHandler _errorHandler = ErrorHandler();

  AccountsController(this._accountRepository);

  // --- State Değişkenleri ---

  // Yüklenme durumu
  final RxBool isLoading = true.obs; // Başlangıçta yükleniyor

  // Hata durumu
  final RxString errorMessage = ''.obs;

  // Hesap Listesi
  final RxList<AccountModel> accountList = <AccountModel>[].obs;

  // --- Lifecycle Metotları ---

  @override
  void onInit() {
    super.onInit();
    print('>>> AccountsController onInit called');
    // Controller ilk oluşturulduğunda hesapları çek
    fetchAccounts();
  }

  // --- Metotlar ---

  /// Kullanıcının hesaplarını API'den çeker ve state'i günceller.
  Future<void> fetchAccounts() async {
    isLoading.value = true;
    errorMessage.value = ''; // Hata mesajını temizle

    try {
      final result = await _accountRepository.getUserAccounts();

      result.when(
        success: (accounts) {
          // Başarılı: Hesap listesini güncelle
          accountList.assignAll(accounts);
          print(
              '>>> Accounts fetched successfully: ${accounts.length} accounts.');
        },
        failure: (error) {
          // Başarısız: Hata mesajını state'e ata
          print('>>> Failed to fetch accounts: ${error.message}');
          errorMessage.value = error.message;

          _errorHandler.handleError(
            error,
            message: errorMessage.value,
            onRetry: () => fetchAccounts(),
            customTitle: 'Hesaplar Yüklenemedi',
          );
        },
      );
    } on UnexpectedException catch (e) {
      // Beklenmedik genel hatalar
      print('>>> Fetch accounts unexpected error: $e');
      errorMessage.value = 'Hesaplar yüklenirken beklenmedik bir hata oluştu.';

      _errorHandler.handleError(e, message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Verileri manuel olarak yenilemek için metot (Pull-to-refresh vb.).
  Future<void> refreshAccounts() async {
    await fetchAccounts();
  }

  /// Belirli bir hesabı siler.
  Future<void> deleteAccount(int accountId) async {
    // TODO: Kullanıcıya onay dialog'u gösterilebilir.

    isLoading.value = true; // Silme işlemi sırasında indicator gösterilebilir
    errorMessage.value = '';

    try {
      final result = await _accountRepository.deleteAccount(accountId);

      result.when(
        success: (_) {
          // Başarılı: Listeden hesabı kaldır ve başarı mesajı göster
          accountList.removeWhere((account) => account.id == accountId);
          print('>>> Account deleted successfully: ID $accountId');

          // Hesap silindikten sonra toplam bakiye vb. güncellenebilir (DashboardController'a haber verilebilir)
        },
        failure: (error) {
          // Başarısız: Hata mesajını göster
          print('>>> Failed to delete account: ${error.message}');
          errorMessage.value = error.message;

          _errorHandler.handleError(
            error,
            message: errorMessage.value,
            customTitle: 'Hesap Silinemedi',
          );
        },
      );
    } on UnexpectedException catch (e) {
      print('>>> Delete account unexpected error: $e');
      errorMessage.value = 'Hesap silinirken beklenmedik bir hata oluştu.';

      _errorHandler.handleError(e, message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Yeni hesap ekleme ekranına yönlendirir.
  void goToAddAccount() {
    Get.toNamed(AppRoutes.ADD_EDIT_ACCOUNT)?.then((result) {
      // Yeni hesap eklendikten sonra bu ekrana geri dönüldüğünde
      // liste otomatik olarak güncellenebilir.
      if (result == true) {
        // Örnek: Ekleme ekranı başarılı olursa true dönsün
        refreshAccounts();
      }
    });
  }

  /// Hesap düzenleme ekranına yönlendirir.
  void goToEditAccount(AccountModel account) {
    // TODO: Hesap düzenleme ekranına git (Get.toNamed ile account ID veya nesnesini gönder)
    Get.toNamed(AppRoutes.ADD_EDIT_ACCOUNT, arguments: account)?.then((result) {
      if (result == true) {
        refreshAccounts();
      }
    });
    print('Edit account tıklandı: ${account.id}');
  }
}
