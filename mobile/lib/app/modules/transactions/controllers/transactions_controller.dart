import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/request/transaction_request_models.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:mobile/app/services/base_controller_mixin.dart';
import 'package:mobile/app/theme/app_colors.dart'; // Tema renkleri

/// İşlemler ekranının state'ini ve iş mantığını yöneten GetX controller.
class TransactionsController extends GetxController
    with RefreshableControllerMixin {
  // Repository'leri inject et (Binding üzerinden)
  final ITransactionRepository _transactionRepository;
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;

  //final ErrorHandler _errorHandler = ErrorHandler();

  TransactionsController({
    required ITransactionRepository transactionRepository,
    required IAccountRepository accountRepository,
    required ICategoryRepository categoryRepository,
  })  : _transactionRepository = transactionRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository;

  // --- State Değişkenleri ---

  // Yüklenme durumları (isLoading ve errorMessage RefreshableControllerMixin'den geliyor)
  final RxBool isLoadingMore = false.obs; // Daha fazla veri yükleniyor mu?
  final RxBool isFilterLoading = false.obs; // Filtreler yükleniyor mu?

  // İşlem Listesi
  final RxList<TransactionModel> transactionList = <TransactionModel>[].obs;

  // Sayfalama için
  final RxInt _currentPage = 1.obs;
  final int _pageSize = 20; // Sayfa başına işlem sayısı
  final RxBool hasMoreData = true.obs; // Daha fazla veri var mı?

  // Filtreleme için State'ler
  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  final Rx<AccountModel?> selectedAccount = Rx<AccountModel?>(null);
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final Rx<CategoryType?> selectedType = Rx<CategoryType?>(null); // Gelir/Gider
  final RxString sortCriteria = 'date_desc'.obs; // Sıralama kriteri ekledim

  // Geçici filtre state'leri (Tamam butonuna basılana kadar kullanılacak)
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

  // Scroll Controller (sonsuz kaydırma için)
  final ScrollController scrollController = ScrollController();

  // Toplam gelir ve gider değerleri için observable değişkenler
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;

  // Seçilen hızlı tarih filtresi
  final Rx<String?> selectedQuickDate = Rx<String?>(null);

  // Çift istek kontrolü için bir zaman damgası
  DateTime? _lastFetchTimestamp;

  // --- Lifecycle Metotları ---

  @override
  void onInit() {
    super.onInit();
    _logDebug('TransactionsController onInit called');
    // Başlangıçta hem filtreleri hem de ilk sayfa işlemleri çek
    _initializeData();
    // Scroll listener'ı ekle
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  // --- Metotlar ---

  /// Başlangıç verilerini (filtreler ve ilk sayfa) yükler.
  Future<void> _initializeData() async {
    _logDebug('_initializeData çağırıldı');
    await loadData(
      fetchFunc: () async {
        // Önce filtreleri yükle, ardından işlemleri yükle
        await _loadFilterOptions();
        await _fetchTransactionsData();
      },
      loadingErrorMessage: "İşlemler yüklenirken bir hata oluştu.",
    );
  }

  /// Filtreleme için hesap ve kategori listelerini yükler.
  Future<void> _loadFilterOptions() async {
    _logDebug('_loadFilterOptions çağırıldı');
    isFilterLoading.value = true;
    try {
      // Hesapları yükle
      final accountsResult = await _accountRepository.getUserAccounts();
      accountsResult.when(
        success: (accounts) {
          _logDebug('${accounts.length} hesap yüklendi');
          filterAccounts.assignAll(accounts);
        },
        failure: (error) {
          _logDebug("Error loading filter accounts: ${error.message}");
          // Hata durumunda boş liste ata
          filterAccounts.clear();
        },
      );

      // Kategorileri yükle (hem gelir hem gider)
      final expenseCategoriesResult =
          await _categoryRepository.getCategories(CategoryType.Expense);
      final incomeCategoriesResult =
          await _categoryRepository.getCategories(CategoryType.Income);

      final List<CategoryModel> allCategories = [];
      expenseCategoriesResult.when(
        success: (cats) {
          _logDebug('${cats.length} gider kategorisi yüklendi');
          allCategories.addAll(cats);
        },
        failure: (error) {
          _logDebug("Error loading expense categories: ${error.message}");
        },
      );
      incomeCategoriesResult.when(
        success: (cats) {
          _logDebug('${cats.length} gelir kategorisi yüklendi');
          allCategories.addAll(cats);
        },
        failure: (error) {
          _logDebug("Error loading income categories: ${error.message}");
        },
      );

      // Ada göre sırala
      allCategories.sort((a, b) => a.name.compareTo(b.name));
      _logDebug('Toplam ${allCategories.length} kategori yüklendi');
      filterCategories.assignAll(allCategories);
    } catch (e) {
      _logDebug("Error loading filter options: $e");
      // Hata mesajı gösterilebilir
    } finally {
      isFilterLoading.value = false;
    }
  }

  /// İşlemlerin ana veri yükleme işlemini gerçekleştirir.
  /// Bu metot, RefreshableControllerMixin için veri çekme işini yapar.
  Future<void> _fetchTransactionsData() async {
    hasMoreData.value = true;
    _currentPage.value = 1;
    transactionList.clear();

    // Filtre DTO'sunu oluştur
    final filter = TransactionFilterDto(
      accountId: selectedAccount.value?.id,
      categoryId: selectedCategory.value?.id,
      startDate: selectedStartDate.value,
      endDate: selectedEndDate.value,
      type: selectedType.value,
      pageNumber: _currentPage.value,
      pageSize: _pageSize,
    );

    final result = await _transactionRepository.getUserTransactions(filter);

    result.when(
      success: (newTransactions) {
        if (newTransactions.isEmpty) {
          hasMoreData.value = false;
        } else {
          transactionList.addAll(newTransactions);
          hasMoreData.value = newTransactions.length == _pageSize;
        }
        _logDebug(
            'İşlemler yüklendi: ${newTransactions.length} adet, Sayfa: ${_currentPage.value}, Daha fazla veri var mı: ${hasMoreData.value}');
        _calculateTotals();
      },
      failure: (error) {
        _logDebug('İşlemler yüklenirken hata: ${error.message}');
        throw error; // RefreshableControllerMixin hata yönetimi için hatayı fırlat
      },
    );
  }

  /// Daha fazla işlem yükler (sayfalama için)
  Future<void> loadMoreTransactions() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    isLoadingMore.value = true;
    _currentPage.value++;

    try {
      // Filtre DTO'sunu oluştur
      final filter = TransactionFilterDto(
        accountId: selectedAccount.value?.id,
        categoryId: selectedCategory.value?.id,
        startDate: selectedStartDate.value,
        endDate: selectedEndDate.value,
        type: selectedType.value,
        pageNumber: _currentPage.value,
        pageSize: _pageSize,
      );

      final result = await _transactionRepository.getUserTransactions(filter);

      result.when(
        success: (newTransactions) {
          if (newTransactions.isEmpty) {
            hasMoreData.value = false;
          } else {
            transactionList.addAll(newTransactions);
            hasMoreData.value = newTransactions.length == _pageSize;
          }
          _logDebug(
              'Daha fazla işlem yüklendi: ${newTransactions.length} adet, Sayfa: ${_currentPage.value}');
          _calculateTotals();
        },
        failure: (error) {
          _logDebug('Daha fazla işlem yüklenirken hata: ${error.message}');
          _currentPage.value--; // Hata durumunda sayfa numarasını geri al
          super.errorMessage.value = error.message;
        },
      );
    } catch (e) {
      _logDebug('Beklenmeyen hata (loadMoreTransactions): $e');
      _currentPage.value--; // Hata durumunda sayfa numarasını geri al
      super.errorMessage.value =
          'İşlemler yüklenirken beklenmedik bir hata oluştu';
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// İşlemleri API'den çeker (sayfalama ve filtreleme ile).
  /// [isInitialLoad] true ise mevcut listeyi temizler ve sayfayı sıfırlar.
  /// [force] true ise, halihazırda bir yükleme işlemi devam etse bile
  /// yenileme işlemini zorla başlatır
  Future<void> fetchTransactions(
      {bool isInitialLoad = false, bool force = false}) async {
    // İşlem başlatmadan önce debug log ekleyelim
    _logDebug(
        'fetchTransactions çağırıldı: isInitialLoad=$isInitialLoad, force=$force, '
        'current isLoading=${super.isLoading.value}');

    // Son işlem çağrısı ile şu anki çağrı arasındaki farkı kontrol et
    // Çok kısa süre içinde gelen çağrıları engelle (300ms)
    if (_lastFetchTimestamp != null) {
      final difference = DateTime.now().difference(_lastFetchTimestamp!);
      if (difference.inMilliseconds < 300 && !force) {
        _logDebug(
            'Son istekten bu yana çok kısa süre geçti (${difference.inMilliseconds}ms). İstek engellendi.');
        return;
      }
    }

    // Zaman damgasını güncelle
    _lastFetchTimestamp = DateTime.now();

    // Halihazırda yükleme yapılıyorsa ve zorlanmıyorsa, çık
    if (super.isLoading.value && !force) {
      _logDebug('İşlemler zaten yükleniyor, yenileme iptal edildi.');
      return;
    }

    // Force modunda ise önce yükleme durumunu sıfırla
    if (force && super.isLoading.value) {
      _logDebug('Zorla yenileme: Yükleme durumu sıfırlanıyor');
      resetLoadingState();
      // Kısa bir gecikme ekle
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Çağrı tipine göre uygun veri çekme metodunu kullan
    if (isInitialLoad) {
      // Halihazırda token yenileme süreci nedeniyle çağrı yapılıp yapılmadığını
      // kontrol etmek için bir flag ekleyelim
      bool requestStarted = false;

      await loadData(
        fetchFunc: () async {
          // Eğer bu istek zaten başlatıldıysa, ikinci çağrıyı engelle
          if (requestStarted) {
            _logDebug('Duplicate request detected. Skipping...');
            return;
          }
          requestStarted = true;

          await _fetchTransactionsData();
        },
        loadingErrorMessage: 'İşlemler yüklenirken bir hata oluştu',
        preventMultipleRequests: !force,
      );
    } else {
      // Yenileme için loadData değil refreshData kullanılmalı
      await refreshData(
        fetchFunc: _fetchTransactionsData,
        refreshErrorMessage: 'İşlemler yenilenirken bir hata oluştu',
      );
    }

    _logDebug('fetchTransactions tamamlandı');
  }

  /// Kaydırma olaylarını dinler ve listenin sonuna gelindiğinde daha fazla veri yükler.
  void _scrollListener() {
    // Scroll pozisyonu listenin sonuna yaklaştıysa ve yükleme yapılmıyorsa
    // ve daha fazla veri varsa, sonraki sayfayı yükle.
    if (scrollController.position.extentAfter < 200 && // Son 200 piksel kala
        !isLoadingMore.value &&
        hasMoreData.value) {
      loadMoreTransactions();
    }
  }

  /// Filtreleri uygular ve işlemleri yeniden yükler.
  /// Bu metod sadece Tamam butonuna basıldığında çağrılmalı.
  void applyFilters() {
    // Geçici filtre değerlerini gerçek filtrelere uygula
    selectedStartDate.value = tempStartDate.value;
    selectedEndDate.value = tempEndDate.value;
    selectedAccount.value = tempAccount.value;
    selectedCategory.value = tempCategory.value;
    selectedType.value = tempType.value;
    selectedQuickDate.value = tempQuickDate.value;
    sortCriteria.value = tempSortCriteria.value;

    // Verileri yükle
    fetchTransactions(isInitialLoad: true);
  }

  /// Tüm filtreleri temizler - FilterBottomSheet içinde kullanılır
  void clearFilters() {
    // Geçici filtreleri temizle
    tempStartDate.value = null;
    tempEndDate.value = null;
    tempAccount.value = null;
    tempCategory.value = null;
    tempType.value = null;
    tempQuickDate.value = null;
    tempSortCriteria.value = 'date_desc';

    // Seçilen filtreleri de temizle
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedAccount.value = null;
    selectedCategory.value = null;
    selectedType.value = null;
    selectedQuickDate.value = null;
    sortCriteria.value = 'date_desc';

    // Filtreler temizlendiğinde ilk sayfayı yükle
    transactionList.clear();
    _currentPage.value = 1;
    hasMoreData.value = true;
    fetchTransactions(isInitialLoad: true);
  }

  /// Tüm filtreleri uygular ve işlemleri yeniden yükler.
  /// Bottom sheet kapatılırken çağrılır (iptal edilirse çağrılmaz).
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

    // Filtreler temizlendiğinde ilk sayfayı yükle
    await fetchTransactions(isInitialLoad: true);
  }

  /// Filtreleme seansını başlat - Bottom Sheet açıldığında çağrılır
  void startFiltering() async {
    _logDebug('startFiltering çağırıldı');
    // Mevcut filtre değerlerini geçici değişkenlere kopyala
    tempStartDate.value = selectedStartDate.value;
    tempEndDate.value = selectedEndDate.value;
    tempAccount.value = selectedAccount.value;
    tempCategory.value = selectedCategory.value;
    tempType.value = selectedType.value;
    tempQuickDate.value = selectedQuickDate.value;
    tempSortCriteria.value = sortCriteria.value;

    // Eğer filtre listeleri boşsa, yeniden yükle
    if (filterAccounts.isEmpty || filterCategories.isEmpty) {
      _logDebug('Filtre listeleri boş, yeniden yükleniyor');
      await _loadFilterOptions();
    }
  }

  /// Tarih aralığı seçimi için dialog gösterir.
  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      // 5 yıl öncesine kadar
      lastDate: DateTime.now().add(const Duration(days: 1)),
      // Yarına kadar
      initialDateRange: tempStartDate.value != null && tempEndDate.value != null
          ? DateTimeRange(start: tempStartDate.value!, end: tempEndDate.value!)
          : null,
      locale: const Locale('tr', 'TR'),
      // Türkçe locale
      builder: (context, child) {
        // Tema uygulamak için
        return Theme(
          data: Theme.of(context).copyWith(
            // Renkleri tema ile uyumlu hale getir
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary, // Ana renk
                  onPrimary: Colors.white, // Ana renk üzeri yazı
                  surface: Colors.white, // Dialog arkaplanı
                  onSurface: AppColors.textPrimary, // Dialog yazı rengi
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      tempStartDate.value = picked.start;
      // Bitiş tarihine günün sonunu ekleyerek tüm günü kapsamasını sağla (opsiyonel)
      tempEndDate.value = DateTime(
          picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);

      // Özel tarih seçildiğinde hızlı tarih filtresi temizlenir
      tempQuickDate.value = null;
    }
  }

  /// Hesap filtresini ayarlar (geçici değere).
  void selectAccountFilter(AccountModel? account) {
    tempAccount.value = account;
  }

  /// Kategori filtresini ayarlar (geçici değere).
  void selectCategoryFilter(CategoryModel? category) {
    tempCategory.value = category;
  }

  /// Gelir/Gider filtresini ayarlar (geçici değere).
  void selectTypeFilter(CategoryType? type) {
    tempType.value = type;
  }

  // Sıralama kriterini ayarla (geçici değere)
  void setSortingCriteria(String criteria) {
    tempSortCriteria.value = criteria;
  }

  // Hızlı tarih filtresi ayarla (geçici değere)
  void setQuickDateFilter(String? period) {
    tempQuickDate.value = period; // Seçilen değeri güncelle

    final now = DateTime.now();

    switch (period) {
      case 'today':
        tempStartDate.value = DateTime(now.year, now.month, now.day);
        tempEndDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        tempStartDate.value =
            DateTime(yesterday.year, yesterday.month, yesterday.day);
        tempEndDate.value = DateTime(
            yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;

      case 'thisWeek':
        // Haftanın ilk günü (Pazartesi) olarak ayarla
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        tempStartDate.value = DateTime(
            firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
        tempEndDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case 'thisMonth':
        tempStartDate.value = DateTime(now.year, now.month, 1);
        tempEndDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case 'lastMonth':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        tempStartDate.value = DateTime(lastMonth.year, lastMonth.month, 1);
        tempEndDate.value =
            DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59);
        break;

      case 'last3Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
        tempStartDate.value =
            DateTime(threeMonthsAgo.year, threeMonthsAgo.month, 1);
        tempEndDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case 'lastYear':
        final lastYear = DateTime(now.year - 1, now.month, now.day);
        tempStartDate.value =
            DateTime(lastYear.year, lastYear.month, lastYear.day);
        tempEndDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case 'all':
      default:
        tempStartDate.value = null;
        tempEndDate.value = null;
        break;
    }
  }

  /// Filtreleme iptal edildiğinde çağrılır
  void cancelFiltering() {
    // Geçici değerleri sıfırla, değişiklik yapmadan çık
    tempStartDate.value = selectedStartDate.value;
    tempEndDate.value = selectedEndDate.value;
    tempAccount.value = selectedAccount.value;
    tempCategory.value = selectedCategory.value;
    tempType.value = selectedType.value;
    tempQuickDate.value = selectedQuickDate.value;
    tempSortCriteria.value = sortCriteria.value;
  }

  /// Belirli bir işlemi siler.
  Future<void> deleteTransaction(int transactionId) async {
    // Onay dialogu
    final confirm = await Get.defaultDialog<bool>(
      title: "İşlemi Sil",
      middleText:
          "Bu işlemi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.",
      textConfirm: "Sil",
      textCancel: "İptal",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(result: true),
      // Onaylanırsa true döndür
      onCancel: () => Get.back(result: false), // İptal edilirse false döndür
    );

    if (confirm != true) return; // Kullanıcı iptal ettiyse çık

    isLoadingMore.value =
        true; // Silme işlemi sırasında indicator gösterilebilir
    errorMessage.value = '';

    try {
      final result =
          await _transactionRepository.deleteTransaction(transactionId);

      result.when(
        success: (_) {
          // Başarılı: Listeden işlemi kaldır
          transactionList.removeWhere((t) => t.id == transactionId);
          print('>>> Transaction deleted successfully: ID $transactionId');
          Get.snackbar(
            'Başarılı',
            'İşlem başarıyla silindi.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // İşlem silindikten sonra bakiye vb. güncellenebilir
        },
        failure: (error) {
          print('>>> Failed to delete transaction: ${error.message}');
          errorMessage.value = error.message;
          Get.snackbar(
            'Hata',
            'İşlem silinirken bir sorun oluştu: ${error.message}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      print('>>> Delete transaction unexpected error: $e');
      errorMessage.value = 'İşlem silinirken beklenmedik bir hata oluştu.';
      Get.snackbar('Hata', errorMessage.value);
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Yeni işlem ekleme ekranına yönlendirir.
  void goToAddTransaction() {
    Get.toNamed(AppRoutes.ADD_EDIT_TRANSACTION)?.then((result) {
      if (result == true) {
        // Ekleme başarılıysa listeyi yenile
        fetchTransactions(isInitialLoad: true);
      }
    });
  }

  /// İşlem düzenleme ekranına yönlendirir.
  void goToEditTransaction(TransactionModel transaction) {
    // TODO: İşlem düzenleme ekranına git (Get.toNamed ile transaction ID veya nesnesini gönder)
    Get.toNamed(AppRoutes.ADD_EDIT_TRANSACTION, arguments: transaction)
        ?.then((result) {
      if (result == true) {
        // Düzenleme başarılıysa listeyi yenile
        fetchTransactions(isInitialLoad: true); // Veya sadece o öğeyi güncelle
      }
    });
    print('Edit transaction tıklandı: ${transaction.id}');
  }

  // Verileri işlerken toplam gelir ve giderleri hesapla
  void _calculateTotals() {
    double income = 0;
    double expense = 0;

    for (final transaction in transactionList) {
      if (transaction.categoryType == CategoryType.Income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
  }

  /// Aktif filtre olup olmadığını kontrol eder
  bool get hasActiveFilters {
    return selectedAccount.value != null ||
        selectedCategory.value != null ||
        selectedType.value != null ||
        selectedStartDate.value != null ||
        selectedQuickDate.value != null;
  }

  /// Özet kart için hızlı tarih filtresi ayarla (doğrudan gerçek değişkenleri günceller)
  Future<void> applyQuickDateFilter(String? period) async {
    // Eski değerleri kaydet (eğer işlem iptal edilirse geri dönmek için)
    final oldStartDate = selectedStartDate.value;
    final oldEndDate = selectedEndDate.value;
    final oldQuickDate = selectedQuickDate.value;

    // Yeni değerleri ayarla
    selectedQuickDate.value = period;
    final now = DateTime.now();

    try {
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
          // Haftanın ilk günü (Pazartesi) olarak ayarla
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
          selectedStartDate.value =
              DateTime(lastMonth.year, lastMonth.month, 1);
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

      // Verileri yükle
      await fetchTransactions(isInitialLoad: true);
    } catch (e) {
      // Hata durumunda eski değerlere geri dön
      selectedStartDate.value = oldStartDate;
      selectedEndDate.value = oldEndDate;
      selectedQuickDate.value = oldQuickDate;
      rethrow;
    }
  }

  /// Özet kart için tarih aralığı seçim popup menüsünü gösterir
  void showQuickDateMenu(BuildContext context, Offset position) {
    // Ekran ölçülerini al
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // Menünün tam butonun altında başlaması için
    final RelativeRect rect = RelativeRect.fromLTRB(
        position.dx, // Sol
        position.dy + 40, // Üst - butonun alt kısmından başlat
        overlay.size.width -
            position.dx, // Sağ - ekran genişliğinden sol pozisyonu çıkar
        overlay.size.height -
            position.dy -
            40 // Alt - ekran yüksekliğinden üst pozisyonu çıkar
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
        selectDateRange(context); // Özel tarih seçimi için takvimi göster
      } else {
        applyQuickDateFilter(value); // Hızlı tarih filtresi uygula
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

  /// Debug modunda log basar
  void _logDebug(String message) {
    if (kDebugMode) {
      print('>>> TransactionsController: $message');
    }
  }
}
