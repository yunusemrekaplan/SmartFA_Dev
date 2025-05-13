import 'package:get/get.dart';

/// Bütçe ekranında dönem seçimi ve yönetimini sağlayan servis sınıfı
class BudgetPeriodService {
  // Filtreleme için seçili dönem (ay/yıl)
  final Rx<DateTime> selectedPeriod = DateTime.now().obs;

  /// Dönemi değiştirir
  void changePeriod(DateTime newPeriod) {
    selectedPeriod.value = newPeriod;
  }

  /// Sonraki aya geçer
  DateTime goToNextMonth() {
    final DateTime currentPeriod = selectedPeriod.value;
    final DateTime nextMonth = DateTime(
      currentPeriod.year + (currentPeriod.month == 12 ? 1 : 0),
      currentPeriod.month == 12 ? 1 : currentPeriod.month + 1,
    );
    selectedPeriod.value = nextMonth;
    return nextMonth;
  }

  /// Önceki aya geçer
  DateTime goToPreviousMonth() {
    final DateTime currentPeriod = selectedPeriod.value;
    final DateTime previousMonth = DateTime(
      currentPeriod.year - (currentPeriod.month == 1 ? 1 : 0),
      currentPeriod.month == 1 ? 12 : currentPeriod.month - 1,
    );
    selectedPeriod.value = previousMonth;
    return previousMonth;
  }

  /// Türkçe ay adını formatlar
  String formatMonthName(DateTime date) {
    // Türkçe ay isimleri
    const List<String> months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Mevcut yıldan önceki ve sonraki belirli sayıda ayı içeren liste döndürür
  List<DateTime> getAvailablePeriods(
      {int monthsBefore = 6, int monthsAfter = 5}) {
    final DateTime now = DateTime.now();
    final List<DateTime> periods = [];

    // Önceki aylar
    for (int i = monthsBefore; i > 0; i--) {
      int month = now.month - i;
      int year = now.year;

      while (month <= 0) {
        month += 12;
        year--;
      }

      periods.add(DateTime(year, month));
    }

    // Mevcut ay
    periods.add(DateTime(now.year, now.month));

    // Sonraki aylar
    for (int i = 1; i <= monthsAfter; i++) {
      int month = now.month + i;
      int year = now.year;

      while (month > 12) {
        month -= 12;
        year++;
      }

      periods.add(DateTime(year, month));
    }

    return periods;
  }
}
