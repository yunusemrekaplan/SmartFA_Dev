import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/modules/accounts/services/account_data_service.dart';
import 'package:mobile/app/modules/accounts/services/account_navigation_service.dart';
import 'package:mobile/app/modules/accounts/services/account_ui_service.dart';

/// Hesaplar ekranının controller'ı
/// DIP (Dependency Inversion Principle) - Yüksek seviyeli modüller düşük seviyeli modüllere bağlı değil
/// Hem yüksek seviyeli hem de düşük seviyeli modüller soyutlamalara bağlı
class AccountsController extends GetxController {
  // Servisler - Bağımlılık Enjeksiyonu
  final AccountDataService _dataService;
  final AccountNavigationService _navigationService;
  final AccountUIService _uiService;

  AccountsController({
    required AccountDataService dataService,
    required AccountNavigationService navigationService,
    required AccountUIService uiService,
  })  : _dataService = dataService,
        _navigationService = navigationService,
        _uiService = uiService;

  // --- Convenience Getters (Delegasyon Paterni) ---

  // Veri Servisi Delegasyonları
  RxBool get isLoading => _dataService.isLoading;
  RxString get errorMessage => _dataService.errorMessage;
  RxList<AccountModel> get accountList => _dataService.accountList;
  double get totalBalance => _dataService.calculateTotalBalance();

  // --- Lifecycle Metotları ---

  @override
  void onInit() {
    super.onInit();
    // Controller ilk oluşturulduğunda hesapları çek
    fetchAccounts();
  }

  // --- Metotlar ---

  /// Kullanıcının hesaplarını API'den çeker ve state'i günceller.
  Future<void> fetchAccounts() async {
    await _dataService.fetchAccounts();
  }

  /// Verileri manuel olarak yenilemek için metot (Pull-to-refresh vb.).
  Future<void> refreshAccounts() async {
    await fetchAccounts();
  }

  /// Belirli bir hesabı siler.
  Future<void> deleteAccount(int accountId) async {
    await _dataService.deleteAccount(accountId);
  }

  /// Yeni hesap ekleme ekranına yönlendirir.
  void goToAddAccount() {
    _navigationService.goToAddAccount().then((result) {
      if (result == true) {
        refreshAccounts();
      }
    });
  }

  /// Hesap düzenleme ekranına yönlendirir.
  void goToEditAccount(AccountModel account) {
    _navigationService.goToEditAccount(account).then((result) {
      if (result == true) {
        refreshAccounts();
      }
    });
  }

  /// Hesap silme onay dialogunu gösterir ve onaylanırsa hesabı siler
  Future<void> confirmAndDeleteAccount(AccountModel account) async {
    final result = await _uiService.showDeleteConfirmation(account);

    if (result == true) {
      await deleteAccount(account.id);
    }
  }
}
