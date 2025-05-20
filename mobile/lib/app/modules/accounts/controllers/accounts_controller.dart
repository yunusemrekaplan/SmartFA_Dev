import 'package:get/get.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';
import 'package:mobile/app/modules/accounts/services/account_data_service.dart';
import 'package:mobile/app/modules/accounts/services/account_navigation_service.dart';
import 'package:mobile/app/modules/accounts/services/account_ui_service.dart';
import 'package:mobile/app/services/base_controller_mixin.dart';

/// Hesaplar ekranının controller'ı
/// DIP (Dependency Inversion Principle) - Yüksek seviyeli modüller düşük seviyeli modüllere bağlı değil
/// Hem yüksek seviyeli hem de düşük seviyeli modüller soyutlamalara bağlı
class AccountsController extends GetxController with BaseControllerMixin {
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

  // AccountDataService'den RxList'i doğrudan alıyoruz
  RxList<AccountModel> get accountList => _dataService.accountList;

  // Hesapların toplam bakiyesi
  RxDouble get totalBalance => _dataService.totalBalance;

  // --- Lifecycle Metotları ---

  @override
  void onInit() {
    super.onInit();

    // İsLoading ve errorMessage durumlarını senkronize et
    _syncStates();

    // İlk veriler için hesapları yükle
    loadAccounts();
  }

  /// DataService ile veri paylaşımını sağlar
  void _syncStates() {
    // Controller → DataService
    ever(super.isLoading, (value) => _dataService.isLoading.value = value);
    ever(
        super.errorMessage, (value) => _dataService.errorMessage.value = value);

    // DataService → Controller
    ever(_dataService.isLoading, (value) => super.isLoading.value = value);
    ever(
        _dataService.errorMessage, (value) => super.errorMessage.value = value);
  }

  // --- PUBLIC API ---

  /// Hesap verilerini yükler
  Future<void> loadAccounts() async {
    await loadData(
      fetchFunc: () => _dataService.fetchAccounts(),
      loadingErrorMessage: 'Hesaplar yüklenirken bir hata oluştu.',
    );
  }

  /// Belirli bir hesabı siler
  Future<void> deleteAccount(int accountId) async {
    await loadData(
      fetchFunc: () => _dataService.deleteAccount(accountId),
      loadingErrorMessage: 'Hesap silinirken bir hata oluştu.',
      onSuccess: () => loadAccounts(),
    );
  }

  /// Yeni hesap ekleme ekranına yönlendirir
  void goToAddAccount() {
    _navigationService.goToAddAccount().then((result) {
      if (result == true) {
        loadAccounts();
      }
    });
  }

  /// Hesap düzenleme ekranına yönlendirir
  void goToEditAccount(AccountModel account) {
    _navigationService.goToEditAccount(account).then((result) {
      if (result == true) {
        loadAccounts();
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
