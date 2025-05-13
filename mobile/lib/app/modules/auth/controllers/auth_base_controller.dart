import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/utils/error_handler.dart';

/// Auth modülü için kullanılan controller'ların temel sınıfı.
/// Ortak özellikleri ve davranışları içerir.
abstract class AuthBaseController extends GetxController {
  final IAuthRepository repository;
  final ErrorHandler errorHandler = ErrorHandler();

  AuthBaseController({required this.repository});

  // State değişkenleri
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Form doğrulama ve işlem başlatma aşamasını hazırlar
  bool prepareForProcessing(GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    return true;
  }

  /// İşlemi tamamladıktan sonra yapılacak işlemler
  void completeProcessing({bool success = false}) {
    isLoading.value = false;
  }

  /// Genel hatanın işlenmesi
  void handleGeneralError(AppException error, {String customTitle = 'Hata'}) {
    errorHandler.handleError(error, message: errorMessage.value);
  }

  /// Form inputları için ortak temizleme metodu
  void clearFormInputs(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      controller.clear();
    }
  }

  @override
  void onClose() {
    // Controller dispose işlemleri burada yapılacak
    super.onClose();
  }
}
