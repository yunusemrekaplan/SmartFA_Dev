import 'package:get/get.dart';

/// Bütçe dönemi yönetim servisi - SRP (Single Responsibility) prensibi
class BudgetPeriodService {
  // Dönem verileri
  final month = RxInt(DateTime.now().month);
  final year = RxInt(DateTime.now().year);

  BudgetPeriodService();

  /// Dönemi belirli bir tarihe ayarlar
  void setupPeriod(int month, int year) {
    this.month.value = month;
    this.year.value = year;
  }

  /// Mevcut ayı ayarlar
  void setMonth(int month) {
    if (month > 0 && month <= 12) {
      this.month.value = month;
    }
  }

  /// Mevcut yılı ayarlar
  void setYear(int year) {
    if (year >= DateTime.now().year) {
      this.year.value = year;
    }
  }

  /// Önceki aya gider
  void goToPreviousMonth() {
    if (month.value > 1) {
      month.value--;
    } else {
      month.value = 12;
      year.value--;
    }
  }

  /// Sonraki aya gider
  void goToNextMonth() {
    if (month.value < 12) {
      month.value++;
    } else {
      month.value = 1;
      year.value++;
    }
  }

  /// Belirli bir ayın adını döndürür
  String getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  /// Mevcut ayın adını döndürür
  String getCurrentMonthName() {
    return getMonthName(month.value);
  }

  /// Mevcut dönemi formatlı string olarak döndürür
  String getFormattedPeriod() {
    return '${getMonthName(month.value)} ${year.value}';
  }
}
