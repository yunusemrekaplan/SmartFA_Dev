import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/request/transaction_request_models.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';
import 'package:mobile/app/domain/models/response/category_response_model.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// İşlem filtreleme işlemlerini yöneten servis sınıfı
class TransactionFilterService {
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;

  // Filtre seçenekleri
  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  final Rx<AccountModel?> selectedAccount = Rx<AccountModel?>(null);
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final Rx<CategoryType?> selectedType = Rx<CategoryType?>(null);
  final RxString sortCriteria = 'date_desc'.obs;
  final Rx<String?> selectedQuickDate = Rx<String?>(null);

  // Geçici filtre state'leri
  final Rx<DateTime?> tempStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> tempEndDate = Rx<DateTime?>(null);
  final Rx<AccountModel?> tempAccount = Rx<AccountModel?>(null);
  final Rx<CategoryModel?> tempCategory = Rx<CategoryModel?>(null);
  final Rx<CategoryType?> tempType = Rx<CategoryType?>(null);
  final Rx<String?> tempQuickDate = Rx<String?>(null);
  final RxString tempSortCriteria = 'date_desc'.obs;

  // Filtre seçeneklerini tutacak listeler
  final RxList<AccountModel> filterAccounts = <AccountModel>[].obs;
  final RxList<CategoryModel> filterCategories = <CategoryModel>[].obs;

  // Yükleme durumu
  final RxBool isFilterLoading = false.obs;
  final RxString errorMessage = ''.obs;

  TransactionFilterService(this._accountRepository, this._categoryRepository);

  /// Filtreleme için hesap ve kategori listelerini yükler
  Future<bool> loadFilterOptions() async {
    isFilterLoading.value = true;
    errorMessage.value = '';

    try {
      // Hesapları yükle
      final accountsResult = await _accountRepository.getUserAccounts();
      final success1 = accountsResult.when(
        success: (accounts) {
          filterAccounts.assignAll(accounts);
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          return false;
        },
      );

      // Kategorileri yükle
      final categoriesResult = await _categoryRepository.getAllCategories();
      final success2 = categoriesResult.when(
        success: (categories) {
          filterCategories.assignAll(categories);
          return true;
        },
        failure: (error) {
          errorMessage.value = error.message;
          return false;
        },
      );

      return success1 && success2;
    } catch (e) {
      print('>>> Unexpected error while loading filter options: $e');
      errorMessage.value =
          'Filtre seçenekleri yüklenirken beklenmedik bir hata oluştu';
      return false;
    } finally {
      isFilterLoading.value = false;
    }
  }

  /// Geçici filtreleri uygular
  void applyFilters() {
    selectedStartDate.value = tempStartDate.value;
    selectedEndDate.value = tempEndDate.value;
    selectedAccount.value = tempAccount.value;
    selectedCategory.value = tempCategory.value;
    selectedType.value = tempType.value;
    selectedQuickDate.value = tempQuickDate.value;
    sortCriteria.value = tempSortCriteria.value;
  }

  /// Geçici filtreleri mevcut filtrelerle senkronize eder
  void startFiltering() {
    tempStartDate.value = selectedStartDate.value;
    tempEndDate.value = selectedEndDate.value;
    tempAccount.value = selectedAccount.value;
    tempCategory.value = selectedCategory.value;
    tempType.value = selectedType.value;
    tempQuickDate.value = selectedQuickDate.value;
    tempSortCriteria.value = sortCriteria.value;
  }

  /// Tüm filtreleri sıfırlar
  Future<void> clearAndApplyFilters() async {
    // Gerçek filtreleri temizle
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedAccount.value = null;
    selectedCategory.value = null;
    selectedType.value = null;
    selectedQuickDate.value = null;
    sortCriteria.value = 'date_desc';

    // Geçici filtreleri de temizle
    tempStartDate.value = null;
    tempEndDate.value = null;
    tempAccount.value = null;
    tempCategory.value = null;
    tempType.value = null;
    tempQuickDate.value = null;
    tempSortCriteria.value = 'date_desc';
  }

  /// Filtreleme iptal edildiğinde çağrılır
  void cancelFiltering() {
    tempStartDate.value = selectedStartDate.value;
    tempEndDate.value = selectedEndDate.value;
    tempAccount.value = selectedAccount.value;
    tempCategory.value = selectedCategory.value;
    tempType.value = selectedType.value;
    tempQuickDate.value = selectedQuickDate.value;
    tempSortCriteria.value = sortCriteria.value;
  }

  /// Tarih aralığı seçimi için dialog gösterir
  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: tempStartDate.value != null && tempEndDate.value != null
          ? DateTimeRange(start: tempStartDate.value!, end: tempEndDate.value!)
          : null,
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      tempStartDate.value = picked.start;
      tempEndDate.value = DateTime(
          picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      tempQuickDate.value = null;
    }
  }

  /// Hızlı tarih filtresi uygular
  Future<void> applyQuickDateFilter(String? period) async {
    selectedQuickDate.value = period;
    final now = DateTime.now();

    switch (period) {
      case 'today':
        selectedStartDate.value = DateTime(now.year, now.month, now.day);
        selectedEndDate.value =
            DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        selectedStartDate.value =
            DateTime(yesterday.year, yesterday.month, yesterday.day);
        selectedEndDate.value = DateTime(
            yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;

      case 'thisWeek':
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        selectedStartDate.value = DateTime(
            firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
        selectedEndDate.value =
            DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case 'thisMonth':
        selectedStartDate.value = DateTime(now.year, now.month, 1);
        selectedEndDate.value =
            DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case 'lastMonth':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        selectedStartDate.value = DateTime(lastMonth.year, lastMonth.month, 1);
        selectedEndDate.value =
            DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59);
        break;

      case 'last3Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
        selectedStartDate.value =
            DateTime(threeMonthsAgo.year, threeMonthsAgo.month, 1);
        selectedEndDate.value =
            DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case 'lastYear':
        final lastYear = DateTime(now.year - 1, now.month, now.day);
        selectedStartDate.value =
            DateTime(lastYear.year, lastYear.month, lastYear.day);
        selectedEndDate.value =
            DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case 'all':
      default:
        selectedStartDate.value = null;
        selectedEndDate.value = null;
        selectedQuickDate.value = null;
        break;
    }
  }

  /// Özet kart için tarih aralığı seçim menüsünü gösterir
  void showQuickDateMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect rect = RelativeRect.fromLTRB(
      position.dx,
      position.dy + 40,
      overlay.size.width - position.dx,
      overlay.size.height - position.dy - 40,
    );

    showMenu<String>(
      context: context,
      position: rect,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        _buildPopupMenuItem('all', 'Tüm Zamanlar', Icons.all_inclusive),
        _buildPopupMenuItem('today', 'Bugün', Icons.today),
        _buildPopupMenuItem('yesterday', 'Dün', Icons.history),
        _buildPopupMenuItem('thisWeek', 'Bu Hafta', Icons.view_week),
        _buildPopupMenuItem('thisMonth', 'Bu Ay', Icons.calendar_view_month),
        _buildPopupMenuItem('lastMonth', 'Geçen Ay', Icons.calendar_month),
        _buildPopupMenuItem('last3Months', 'Son 3 Ay', Icons.date_range),
        _buildPopupMenuItem('lastYear', 'Son 1 Yıl', Icons.calendar_today),
        PopupMenuItem<String>(
          value: 'custom',
          child: Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text('Özel Tarih Aralığı'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null) return;

      if (value == 'custom') {
        selectDateRange(context);
      } else {
        applyQuickDateFilter(value);
      }
    });
  }

  /// Popup menü öğesi oluşturur
  PopupMenuItem<String> _buildPopupMenuItem(
      String value, String text, IconData icon) {
    final bool isSelected = selectedQuickDate.value == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (isSelected) Icon(Icons.check, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  /// Mevcut filtre durumuna göre DTO oluşturur
  TransactionFilterDto createFilterDto(
      {int pageNumber = 1, int pageSize = 20}) {
    return TransactionFilterDto(
      accountId: selectedAccount.value?.id,
      categoryId: selectedCategory.value?.id,
      startDate: selectedStartDate.value,
      endDate: selectedEndDate.value,
      type: selectedType.value,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  /// Aktif filtre olup olmadığını kontrol eder
  bool get hasActiveFilters {
    return selectedStartDate.value != null ||
        selectedEndDate.value != null ||
        selectedAccount.value != null ||
        selectedCategory.value != null ||
        selectedType.value != null ||
        sortCriteria.value != 'date_desc';
  }
}
