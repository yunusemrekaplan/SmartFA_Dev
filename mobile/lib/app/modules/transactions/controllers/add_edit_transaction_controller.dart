import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/request/transaction_request_models.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';
import 'package:mobile/app/domain/models/response/category_response_model.dart';
import 'package:mobile/app/domain/models/response/transaction_response_model.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';

class AddEditTransactionController extends GetxController {
  final ITransactionRepository _transactionRepository;
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;

  AddEditTransactionController({
    required ITransactionRepository transactionRepository,
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
  })  : _transactionRepository = transactionRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository;

  // Form anahtarı
  final formKey = GlobalKey<FormState>();

  // Text controller'lar
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  // State değişkenleri
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<CategoryType> selectedType = CategoryType.Income.obs;
  final Rx<AccountModel?> selectedAccount = Rx<AccountModel?>(null);
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Listeler
  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // Düzenleme modu için
  final RxBool isEditing = false.obs;
  final Rx<TransactionModel?> editingTransaction = Rx<TransactionModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    _checkIfEditing();
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void _checkIfEditing() {
    final args = Get.arguments;
    if (args is TransactionModel) {
      isEditing.value = true;
      editingTransaction.value = args;
      _populateFormWithTransaction(args);
    }
  }

  void _populateFormWithTransaction(TransactionModel transaction) {
    selectedType.value = transaction.categoryType;
    amountController.text = transaction.amount.toString();
    notesController.text = transaction.notes ?? '';
    selectedDate.value = transaction.transactionDate;
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Hesapları yükle
      final accountsResult = await _accountRepository.getUserAccounts();
      accountsResult.when(
        success: (loadedAccounts) => accounts.value = loadedAccounts,
        failure: (error) => errorMessage.value = error.message,
      );

      // Kategorileri yükle
      final categoriesResult =
          await _categoryRepository.getCategories(selectedType.value);
      categoriesResult.when(
        success: (loadedCategories) {
          categories.value = loadedCategories;
          // İlk kategoriyi seç
          if (categories.isNotEmpty) {
            selectedCategory.value = categories.firstWhere(
              (category) => category.type == selectedType.value,
              orElse: () => categories.first,
            );
          }
        },
        failure: (error) => errorMessage.value = error.message,
      );

      // İlk hesabı seç
      if (accounts.isNotEmpty) {
        selectedAccount.value = accounts.first;
      }
    } catch (e) {
      errorMessage.value = 'Veriler yüklenirken bir hata oluştu.';
    } finally {
      isLoading.value = false;
    }
  }

  void selectType(CategoryType type) async {
    selectedType.value = type;

    if (categories.isEmpty) {
      selectedCategory.value = null;
      return;
    }

    // Kategorileri güncelle
    final categoriesResult = await _categoryRepository.getCategories(type);
    categoriesResult.when(
      success: (loadedCategories) {
        categories.value = loadedCategories;
        // İlk kategoriyi seç
        if (categories.isNotEmpty) {
          selectedCategory.value = categories.firstWhere(
            (category) => category.type == type,
            orElse: () => categories.first,
          );
        }
      },
      failure: (error) => errorMessage.value = error.message,
    );

    // Seçilen tipe göre ilk kategoriyi bul
    final matchingCategory = categories.firstWhere(
      (category) => category.type == type,
      orElse: () => categories.first,
    );

    selectedCategory.value = matchingCategory;
  }

  void selectAccount(AccountModel account) {
    selectedAccount.value = account;
  }

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> saveTransaction() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedAccount.value == null) {
      errorMessage.value = 'Lütfen bir hesap seçin';
      return;
    }

    if (selectedCategory.value == null) {
      errorMessage.value = 'Lütfen bir kategori seçin';
      return;
    }

    isLoading.value = true;
    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      if (isEditing.value) {
        // Düzenleme modu
        final result = await _transactionRepository.updateTransaction(
          editingTransaction.value!.id,
          UpdateTransactionRequestModel(
            accountId: selectedAccount.value!.id,
            categoryId: selectedCategory.value!.id,
            amount: double.parse(amountController.text),
            transactionDate: selectedDate.value,
            notes: notesController.text,
          ),
        );

        result.when(
          success: (_) {
            Get.back(result: true);
            Get.snackbar(
              'Başarılı',
              'İşlem başarıyla güncellendi',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          failure: (error) => errorMessage.value = error.message,
        );
      } else {
        // Yeni işlem ekleme
        final result = await _transactionRepository.createTransaction(
          CreateTransactionRequestModel(
            accountId: selectedAccount.value!.id,
            categoryId: selectedCategory.value!.id,
            amount: double.parse(amountController.text),
            transactionDate: selectedDate.value,
            notes: notesController.text,
          ),
        );

        result.when(
          success: (_) {
            Get.back(result: true);
            Get.snackbar(
              'Başarılı',
              'İşlem başarıyla eklendi',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          failure: (error) => errorMessage.value = error.message,
        );
      }
    } catch (e) {
      errorMessage.value = 'İşlem kaydedilirken bir hata oluştu.';
    } finally {
      isLoading.value = false;
      isSubmitting.value = false;
    }
  }

  Future<void> deleteTransaction() async {
    if (!isEditing.value) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('İşlemi Sil'),
        content: const Text('Bu işlemi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;
    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final result = await _transactionRepository.deleteTransaction(
        editingTransaction.value!.id,
      );

      result.when(
        success: (_) {
          Get.back(result: true);
          Get.snackbar(
            'Başarılı',
            'İşlem başarıyla silindi',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        failure: (error) => errorMessage.value = error.message,
      );
    } catch (e) {
      errorMessage.value = 'İşlem silinirken bir hata oluştu.';
    } finally {
      isLoading.value = false;
      isSubmitting.value = false;
    }
  }
}
