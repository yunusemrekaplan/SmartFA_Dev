import 'package:get/get.dart';
import 'package:mobile/app/core/services/snackbar/i_snackbar_service.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/request/transaction_request_models.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';
import 'package:mobile/app/domain/models/response/category_response_model.dart';
import 'package:mobile/app/domain/models/response/transaction_response_model.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';

/// İşlem ekleme/düzenleme işlemlerini yöneten servis sınıfı
class TransactionAddEditService {
  final ITransactionRepository _transactionRepository;
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;
  final _snackbarService = Get.find<ISnackbarService>();

  // Yükleme durumları
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Form state'leri
  final Rx<CategoryType> selectedType = CategoryType.Income.obs;
  final Rx<AccountModel?> selectedAccount = Rx<AccountModel?>(null);
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Listeler
  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // Düzenleme modu
  final RxBool isEditing = false.obs;
  final Rx<TransactionModel?> editingTransaction = Rx<TransactionModel?>(null);

  TransactionAddEditService(
    this._transactionRepository,
    this._accountRepository,
    this._categoryRepository,
  );

  /// İlk verileri yükler
  Future<bool> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Hesapları yükle
      final accountsResult = await _accountRepository.getUserAccounts();
      final success1 = accountsResult.when(
        success: (loadedAccounts) {
          accounts.value = loadedAccounts;
          if (accounts.isNotEmpty) {
            selectedAccount.value = accounts.first;
          }
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          return false;
        },
      );

      // Tüm kategorileri yükle
      final categoriesResult = await _categoryRepository.getAllCategories();
      final success2 = categoriesResult.when(
        success: (loadedCategories) {
          categories.value = loadedCategories;

          // Seçili tipe uygun ilk kategoriyi seç
          if (categories.isNotEmpty) {
            final matchingCategory = categories.firstWhere(
              (category) => category.type == selectedType.value,
              orElse: () => categories.first,
            );
            selectedCategory.value = matchingCategory;
          }
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          return false;
        },
      );

      return success1 && success2;
    } catch (e) {
      print('>>> Unexpected error while loading initial data: $e');
      errorMessage.value = 'Veriler yüklenirken beklenmedik bir hata oluştu';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// İşlem tipine göre kategorileri yeniden yükler
  Future<bool> reloadCategories() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _categoryRepository.getAllCategories();
      return result.when(
        success: (loadedCategories) {
          categories.value = loadedCategories;
          selectedCategory.value = null;

          // Seçili tipe uygun ilk kategoriyi seç
          if (categories.isNotEmpty) {
            final matchingCategory = categories.firstWhere(
              (category) => category.type == selectedType.value,
              orElse: () => categories.first,
            );
            selectedCategory.value = matchingCategory;
          }
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          return false;
        },
      );
    } catch (e) {
      print('>>> Unexpected error while reloading categories: $e');
      errorMessage.value =
          'Kategoriler yüklenirken beklenmedik bir hata oluştu';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// İşlem oluşturur
  Future<bool> createTransaction(CreateTransactionRequestModel model) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final result = await _transactionRepository.createTransaction(model);

      return result.when(
        success: (_) {
          _snackbarService.showSuccess(
            message: 'İşlem başarıyla eklendi',
            title: 'Başarılı',
          );
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          _snackbarService.showError(
            message: error.message,
            title: 'Hata',
          );
          return false;
        },
      );
    } catch (e) {
      print('>>> Unexpected error while creating transaction: $e');
      errorMessage.value = 'İşlem oluşturulurken beklenmedik bir hata oluştu';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// İşlem günceller
  Future<bool> updateTransaction(
      int id, UpdateTransactionRequestModel model) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final result = await _transactionRepository.updateTransaction(id, model);

      return result.when(
        success: (_) {
          _snackbarService.showSuccess(
            message: 'İşlem başarıyla güncellendi',
            title: 'Başarılı',
          );
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          return false;
        },
      );
    } catch (e) {
      print('>>> Unexpected error while updating transaction: $e');
      errorMessage.value = 'İşlem güncellenirken beklenmedik bir hata oluştu';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Düzenleme modunu ayarlar
  void setupEditMode(TransactionModel transaction) {
    isEditing.value = true;
    editingTransaction.value = transaction;
    selectedType.value = transaction.categoryType;
    selectedDate.value = transaction.transactionDate;
  }

  /// Form verilerini temizler
  void resetForm() {
    selectedType.value = CategoryType.Income;
    selectedAccount.value = accounts.isEmpty ? null : accounts.first;
    selectedCategory.value = categories.isEmpty ? null : categories.first;
    selectedDate.value = DateTime.now();
    isEditing.value = false;
    editingTransaction.value = null;
    errorMessage.value = '';
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final result = await _transactionRepository.deleteTransaction(id);

      return result.when(
        success: (_) {
          _snackbarService.showSuccess(
            message: 'İşlem başarıyla silindi',
            title: 'Başarılı',
          );
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          _snackbarService.showError(
            message: error.message,
            title: 'Hata',
          );
          return false;
        },
      );
    } catch (e) {
      print('>>> Unexpected error while deleting transaction: $e');
      errorMessage.value = 'İşlem silinirken beklenmedik bir hata oluştu';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
