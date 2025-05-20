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
import 'package:mobile/app/modules/transactions/services/transaction_add_edit_service.dart';

/// İşlem ekleme/düzenleme ekranının state'ini ve iş mantığını yöneten GetX controller.
class AddEditTransactionController extends GetxController {
  // Servis
  late final TransactionAddEditService _service;

  // Form anahtarı
  final formKey = GlobalKey<FormState>();

  // Text controller'lar
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  AddEditTransactionController({
    required ITransactionRepository transactionRepository,
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
  }) {
    _service = TransactionAddEditService(
      transactionRepository,
      accountRepository,
      categoryRepository,
    );
  }

  // --- Getters ---
  RxBool get isLoading => _service.isLoading;
  RxBool get isSubmitting => _service.isSubmitting;
  RxString get errorMessage => _service.errorMessage;
  Rx<CategoryType> get selectedType => _service.selectedType;
  Rx<AccountModel?> get selectedAccount => _service.selectedAccount;
  Rx<CategoryModel?> get selectedCategory => _service.selectedCategory;
  Rx<DateTime> get selectedDate => _service.selectedDate;
  RxList<AccountModel> get accounts => _service.accounts;
  RxList<CategoryModel> get categories => _service.categories;
  RxBool get isEditing => _service.isEditing;
  Rx<TransactionModel?> get editingTransaction => _service.editingTransaction;

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

  /// İlk verileri yükler
  Future<void> _loadInitialData() async {
    await _service.loadInitialData();
  }

  /// Düzenleme modunu kontrol eder
  void _checkIfEditing() {
    final args = Get.arguments;
    if (args is TransactionModel) {
      _service.setupEditMode(args);
      _populateFormWithTransaction(args);
    }
  }

  /// Form alanlarını mevcut işlem verileriyle doldurur
  void _populateFormWithTransaction(TransactionModel transaction) {
    amountController.text = transaction.amount.toString();
    notesController.text = transaction.notes ?? '';
  }

  /// İşlem tipini değiştirir ve kategorileri yeniden yükler
  Future<void> changeType(CategoryType type) async {
    if (selectedType.value == type) return;
    selectedType.value = type;
    await _service.reloadCategories();
  }

  /// Hesap seçimini günceller
  void selectAccount(AccountModel? account) {
    selectedAccount.value = account;
  }

  /// Kategori seçimini günceller
  void selectCategory(CategoryModel? category) {
    selectedCategory.value = category;
  }

  /// Tarih seçimini günceller
  void selectDate() {
    showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((date) {
      selectedDate.value = date ?? selectedDate.value;
    });
  }

  /// Form verilerini kaydeder
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

    bool success;
    if (isEditing.value) {
      success = await _service.updateTransaction(
        editingTransaction.value!.id,
        UpdateTransactionRequestModel(
          accountId: selectedAccount.value!.id,
          categoryId: selectedCategory.value!.id,
          amount: double.parse(amountController.text),
          transactionDate: selectedDate.value,
          notes: notesController.text,
        ),
      );
    } else {
      success = await _service.createTransaction(
        CreateTransactionRequestModel(
          accountId: selectedAccount.value!.id,
          categoryId: selectedCategory.value!.id,
          amount: double.parse(amountController.text),
          transactionDate: selectedDate.value,
          notes: notesController.text,
        ),
      );
    }

    if (success) {
      Get.back(result: true);
    }
  }

  /// İşlemi siler
  Future<void> deleteTransaction() async {
    await _service.deleteTransaction(editingTransaction.value!.id);
  }

  /// Form verilerini temizler
  void resetForm() {
    _service.resetForm();
    amountController.clear();
    notesController.clear();
  }
}
