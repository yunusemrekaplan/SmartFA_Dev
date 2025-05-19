import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/enums/account_type.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';
import 'package:mobile/app/modules/accounts/services/account_form_service.dart';
import 'package:mobile/app/modules/accounts/services/account_navigation_service.dart';
import 'package:mobile/app/modules/accounts/services/account_ui_service.dart';
import 'package:mobile/app/modules/accounts/services/account_update_service.dart';
import 'package:mobile/app/services/dialog_service.dart';

/// Hesap ekleme ve düzenleme ekranının controller'ı
/// DIP (Dependency Inversion Principle) - Yüksek seviyeli modüller düşük seviyeli modüllere bağlı değil
/// ISP (Interface Segregation Principle) - Kullanılmayan arayüzlere bağımlı olunmamalı
class AddEditAccountController extends GetxController {
  // Servisler - Bağımlılık Enjeksiyonu
  final AccountFormService _formService;
  final AccountUpdateService _updateService;
  final AccountNavigationService _navigationService;

  AddEditAccountController({
    required AccountFormService formService,
    required AccountUpdateService updateService,
    required AccountNavigationService navigationService,
    required AccountUIService uiService,
  })  : _formService = formService,
        _updateService = updateService,
        _navigationService = navigationService;

  // --- Convenience Getters (Delegasyon Paterni) ---

  // Form Servisi Delegasyonları
  GlobalKey<FormState> get formKey => _formService.formKey;
  TextEditingController get nameController => _formService.nameController;
  TextEditingController get balanceController => _formService.balanceController;
  RxBool get isEditing => _formService.isEditing;
  Rx<AccountModel?> get editingAccount => _formService.editingAccount;
  Rx<AccountType> get selectedAccountType => _formService.selectedAccountType;
  List<AccountType> get accountTypes => _formService.accountTypes;
  RxBool get isSubmitting => _formService.isSubmitting;

  // Güncelleme Servisi Delegasyonları
  RxBool get isLoading => _updateService.isLoading;
  RxString get errorMessage => _updateService.errorMessage;

  // --- Lifecycle Metotları ---

  @override
  void onInit() {
    super.onInit();
    _initializeScreen();
  }

  @override
  void onClose() {
    _formService.dispose();
    super.onClose();
  }

  /// Ekranı başlatır ve düzenleme modunu kontrol eder
  Future<void> _initializeScreen() async {
    // Get.arguments'dan düzenlenecek hesap verisini al (varsa)
    final arguments = Get.arguments;

    if (arguments != null && arguments is AccountModel) {
      // Düzenleme modu
      _formService.setupEditMode(arguments);
    } else {
      // Ekleme modu
      _formService.setupAddMode();
    }
  }

  /// Hesap türünü seçer
  void selectAccountType(AccountType type) {
    _formService.selectAccountType(type);
  }

  /// Hesap verilerini kaydeder (ekle veya güncelle)
  Future<void> saveAccount() async {
    // Form validasyonu
    if (!_formService.validateForm()) {
      return;
    }

    _formService.startSubmitting();

    try {
      bool success;

      if (_formService.isEditing.value &&
          _formService.editingAccount.value != null) {
        // Hesabı güncelle
        success = await _updateService.updateAccount(
          accountId: _formService.editingAccount.value!.id,
          name: _formService.getName(),
        );
      } else {
        // Yeni hesap ekle
        success = await _updateService.createAccount(
          name: _formService.getName(),
          initialBalance: _formService.getInitialBalance(),
          type: _formService.getAccountType(),
        );
      }

      if (success) {
        _navigationService.goBack(result: true);
      }
    } finally {
      _formService.finishSubmitting();
    }
  }

  /// Hesabı siler
  Future<void> deleteAccount() async {
    if (!_formService.isEditing.value ||
        _formService.editingAccount.value == null) {
      return;
    }

    // Silme onayı
    final confirm = await DialogService.showDeleteConfirmationDialog(
      title: 'Hesabı Sil',
      message:
          'Bu hesabı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
      onConfirm:
          null, // Dialog kapanınca işlem yapmak istemiyoruz, result'ı kullanacağız
    );

    if (confirm != true) {
      return;
    }

    _formService.startSubmitting();

    try {
      final success = await _updateService.deleteAccount(
        _formService.editingAccount.value!.id,
      );

      if (success) {
        _navigationService.goBack(result: true);
      }
    } finally {
      _formService.finishSubmitting();
    }
  }

  /// Hesap türünün görünen adını döndürür
  String getAccountTypeDisplayName(AccountType type) {
    return _formService.getAccountTypeDisplayName(type);
  }
}
