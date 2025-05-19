import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/enums/account_type.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';

/// Hesap formunu yöneten servis
/// SRP (Single Responsibility Principle) - Form işlemleri ve validasyon tek bir sınıfta toplanır
class AccountFormService {
  // Form control
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final balanceController = TextEditingController();

  // Form state
  final RxBool isEditing = false.obs;
  final Rx<AccountModel?> editingAccount = Rx<AccountModel?>(null);
  final Rx<AccountType> selectedAccountType = AccountType.Cash.obs;
  final RxBool isSubmitting = false.obs;

  // Hesap türleri listesi
  final List<AccountType> accountTypes = AccountType.values;

  AccountFormService();

  /// Form kontrollerini temizler
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
  }

  /// Hesap türünü seçer
  void selectAccountType(AccountType type) {
    selectedAccountType.value = type;
  }

  /// Form validasyonunu yapar
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Düzenleme modunda hesap verilerini form alanlarına yükler
  void setupEditMode(AccountModel account) {
    isEditing.value = true;
    editingAccount.value = account;

    // Form alanlarını doldur
    nameController.text = account.name;
    //balanceController.text = account.currency.toString();
    selectedAccountType.value = account.type;
  }

  /// Ekleme modu için formu hazırlar
  void setupAddMode() {
    isEditing.value = false;
    editingAccount.value = null;

    // Varsayılan değerler
    nameController.clear();
    //balanceController.text = '0.00';
    selectedAccountType.value = AccountType.Cash;
  }

  /// Hesap adını alır
  String getName() {
    return nameController.text.trim();
  }

  /// Başlangıç bakiyesini alır
  double getInitialBalance() {
    return double.parse(balanceController.text.replaceAll(',', '.'));
  }

  /// Seçilen hesap türünü alır
  AccountType getAccountType() {
    return selectedAccountType.value;
  }

  /// İşlem başlatır
  void startSubmitting() {
    isSubmitting.value = true;
  }

  /// İşlemi bitirir
  void finishSubmitting() {
    isSubmitting.value = false;
  }

  /// Hesap türünün görünen adını döndürür
  String getAccountTypeDisplayName(AccountType type) {
    switch (type) {
      case AccountType.Cash:
        return 'Nakit';
      case AccountType.Bank:
        return 'Banka Hesabı';
      case AccountType.CreditCard:
        return 'Kredi Kartı';
    }
  }
}
