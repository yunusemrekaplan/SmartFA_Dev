import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bütçe formu durum yönetim servisi - SRP (Single Responsibility) prensibi
class BudgetStateService {
  // Form durumu
  final formKey = GlobalKey<FormState>();

  // İşlem durumları
  final isLoading = RxBool(false);
  final isEditing = RxBool(false);
  final budgetId = RxnInt(null);

  // Mesajlar
  final errorMessage = RxString('');
  final successMessage = RxString('');

  BudgetStateService();

  /// Düzenleme modunu ayarlar
  void setupEditMode(int id) {
    isEditing.value = true;
    budgetId.value = id;
  }

  /// Normal mod (yeni bütçe) için ayarlar
  void setupCreateMode() {
    isEditing.value = false;
    budgetId.value = null;
  }

  /// Yükleme durumunu başlatır
  void startLoading() {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Yükleme durumunu sonlandırır
  void stopLoading() {
    isLoading.value = false;
  }

  /// Hata mesajını ayarlar
  void setErrorMessage(String message) {
    errorMessage.value = message;
  }

  /// Başarı mesajını ayarlar
  void setSuccessMessage(String message) {
    successMessage.value = message;
  }

  /// Mesajları temizler
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Formu doğrular
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Durumu döndür (düzenleme mi, ekleme mi)
  bool isEditMode() => isEditing.value;

  /// Bütçe ID'sini döndür
  int? getBudgetId() => budgetId.value;
}
