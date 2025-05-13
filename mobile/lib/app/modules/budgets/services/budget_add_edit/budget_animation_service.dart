import 'dart:async';
import 'package:get/get.dart';

/// Animasyon durumlarını yöneten servis - SRP (Single Responsibility) prensibi
class BudgetAnimationService {
  // Animasyon durumları
  final isFormAnimating = RxBool(true);
  final isCategorySelectedAnimating = RxBool(false);
  final isAmountEnteredAnimating = RxBool(false);
  final isSavingAnimating = RxBool(false);

  BudgetAnimationService() {
    // Form animasyonunu başlat ve belirli bir süre sonra kapat
    Future.delayed(const Duration(milliseconds: 800), () {
      isFormAnimating.value = false;
    });
  }

  /// Kategori seçim animasyonunu başlatır
  void triggerCategoryAnimation() {
    isCategorySelectedAnimating.value = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      isCategorySelectedAnimating.value = false;
    });
  }

  /// Tutar giriş animasyonunu başlatır
  void triggerAmountAnimation() {
    isAmountEnteredAnimating.value = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      isAmountEnteredAnimating.value = false;
    });
  }

  /// Kaydetme animasyonunu başlatır ve belirtilen işlemi yürütür
  Future<void> runWithSaveAnimation(Future<void> Function() task) async {
    isSavingAnimating.value = true;

    try {
      await task();

      // Başarılı işlem sonrası biraz beklet
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      isSavingAnimating.value = false;
    }
  }

  /// Tüm animasyonları sıfırlar
  void resetAnimations() {
    isFormAnimating.value = false;
    isCategorySelectedAnimating.value = false;
    isAmountEnteredAnimating.value = false;
    isSavingAnimating.value = false;
  }
}
