import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/enums/account_type.dart';
import 'package:mobile/app/data/models/request/account_request_models.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';

class AddEditAccountController extends GetxController {
  final IAccountRepository _accountRepository;

  AddEditAccountController({required IAccountRepository accountRepository})
      : _accountRepository = accountRepository;

  // Form control
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final balanceController = TextEditingController();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isEditing = false.obs;
  final Rx<AccountModel?> editingAccount = Rx<AccountModel?>(null);
  final Rx<AccountType> selectedAccountType = AccountType.Cash.obs;

  // Hesap türleri listesi
  final List<AccountType> accountTypes = AccountType.values;

  @override
  void onInit() {
    super.onInit();
    _initializeScreen();
  }

  @override
  void onClose() {
    nameController.dispose();
    balanceController.dispose();
    super.onClose();
  }

  /// Ekranı başlatır ve düzenleme modunu kontrol eder
  Future<void> _initializeScreen() async {
    isLoading.value = true;

    try {
      // Get.arguments'dan düzenlenecek hesap verisini al (varsa)
      final arguments = Get.arguments;

      if (arguments != null && arguments is AccountModel) {
        // Düzenleme modu
        isEditing.value = true;
        editingAccount.value = arguments;
        _loadAccountData(arguments);
      } else {
        // Ekleme modu
        isEditing.value = false;
        selectedAccountType.value = AccountType.Cash;
        balanceController.text = '0.00'; // Varsayılan bakiye
      }
    } catch (e) {
      print('Error initializing account screen: $e');
      Get.snackbar('Hata', 'Veriler yüklenirken bir sorun oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  /// Düzenleme modunda hesap verilerini form alanlarına yükler
  void _loadAccountData(AccountModel account) {
    nameController.text = account.name;
    balanceController.text = account.currency.toString();

    // Hesap türünü seç, eşleşen yoksa ilk seçenek
    selectedAccountType.value = account.type;
  }

  /// Hesap verilerini kaydeder (ekle veya güncelle)
  Future<void> saveAccount() async {
    // Form validasyonu
    if (!formKey.currentState!.validate()) {
      return;
    }

    isSubmitting.value = true;

    try {
      // Girilen değerlerden verileri oluştur
      final accountData = UpdateAccountRequestModel(
        name: nameController.text.trim(),
      );

      if (isEditing.value && editingAccount.value != null) {
        // Hesabı güncelle
        final result = await _accountRepository.updateAccount(
          editingAccount.value!.id,
          accountData,
        );

        result.when(
          success: (_) {
            Get.back(result: true); // Başarılı olarak geri dön
            Get.snackbar('Başarılı', 'Hesap başarıyla güncellendi');
          },
          failure: (error) {
            Get.snackbar('Hata',
                'Hesap güncellenirken bir hata oluştu: ${error.message}');
          },
        );
      } else {
        final accountData = CreateAccountRequestModel(
          name: nameController.text.trim(),
          initialBalance:
              double.parse(balanceController.text.replaceAll(',', '.')),
          type: selectedAccountType.value,
          currency: 'TRY',
        );

        // Yeni hesap ekle
        final result = await _accountRepository.createAccount(accountData);

        result.when(
          success: (_) {
            Get.back(result: true); // Başarılı olarak geri dön
            Get.snackbar('Başarılı', 'Hesap başarıyla eklendi');
          },
          failure: (error) {
            Get.snackbar(
                'Hata', 'Hesap eklenirken bir hata oluştu: ${error.message}');
          },
        );
      }
    } catch (e) {
      print('Error saving account: $e');
      Get.snackbar('Hata', 'Beklenmeyen bir hata oluştu');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Hesabı siler
  Future<void> deleteAccount() async {
    if (!isEditing.value || editingAccount.value == null) {
      return;
    }

    // Silme onayı
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
            'Bu hesabı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('İptal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    isSubmitting.value = true;

    try {
      final result =
          await _accountRepository.deleteAccount(editingAccount.value!.id);

      result.when(
        success: (_) {
          Get.back(result: true); // Başarılı olarak geri dön
          Get.snackbar('Başarılı', 'Hesap başarıyla silindi');
        },
        failure: (error) {
          Get.snackbar(
              'Hata', 'Hesap silinirken bir hata oluştu: ${error.message}');
        },
      );
    } catch (e) {
      print('Error deleting account: $e');
      Get.snackbar('Hata', 'Beklenmeyen bir hata oluştu');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Hesap türünü seçer
  void selectAccountType(AccountType type) {
    selectedAccountType.value = type;
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
