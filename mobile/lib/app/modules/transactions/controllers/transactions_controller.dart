import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/request/transaction_request_models.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:mobile/app/theme/app_colors.dart'; // Tema renkleri

/// İşlemler ekranının state'ini ve iş mantığını yöneten GetX controller.
class TransactionsController extends GetxController {
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

  // Yüklenme durumları
  final RxBool isLoading = true.obs; // Ana liste yükleniyor mu?
  final RxBool isLoadingMore = false.obs; // Daha fazla veri yükleniyor mu?
  final RxBool isFilterLoading = false.obs; // Filtreler yükleniyor mu?

  // Hata durumu
  final RxString errorMessage = ''.obs;

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

  // Filtre seçeneklerini tutacak listeler
  final RxList<AccountModel> filterAccounts = <AccountModel>[].obs;
  final RxList<CategoryModel> filterCategories = <CategoryModel>[].obs;

  // Scroll Controller (sonsuz kaydırma için)
  final ScrollController scrollController = ScrollController();

  // Toplam gelir ve gider değerleri için observable değişkenler
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;

  // Sıralama kriteri
  final RxString sortCriteria = 'date_desc'.obs;

  // Seçilen hızlı tarih filtresi
  final Rx<String?> selectedQuickDate = Rx<String?>(null);

  // --- Lifecycle Metotları ---

  @override
  void onInit() {
    super.onInit();
    print('>>> TransactionsController onInit called');
    // Başlangıçta hem filtreleri hem de ilk sayfa işlemleri çek
    _initializeData();
    // Scroll listener'ı ekle
    scrollController.addListener(_scrollListener);
    fetchTransactions(isInitialLoad: true);
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
    isLoading.value = true; // Genel yükleme başladı
    isFilterLoading.value = true;
    errorMessage.value = '';
    hasMoreData.value = true; // Başlangıçta daha fazla veri olduğunu varsay
    _currentPage.value = 1; // Sayfayı sıfırla
    transactionList.clear(); // Listeyi temizle

    try {
      // Filtre verilerini ve ilk sayfa işlemlerini paralel çek
      await Future.wait([
        _loadFilterOptions(),
        fetchTransactions(isInitialLoad: true), // İlk yükleme olduğunu belirt
      ]);
    } catch (e) {
      // Hata zaten fetchTransactions veya _loadFilterOptions içinde ele alınır.
      // Burada genel bir loglama yapılabilir.
      print("Initialization error: $e");
    } finally {
      isLoading.value = false; // Genel yükleme bitti
      isFilterLoading.value = false;
    }
  }

  /// Filtreleme için hesap ve kategori listelerini yükler.
  Future<void> _loadFilterOptions() async {
    try {
      // Hesapları yükle
      final accountsResult = await _accountRepository.getUserAccounts();
      accountsResult.when(
        success: (accounts) => filterAccounts.assignAll(accounts),
        failure: (error) => print(
            "Error loading filter accounts: ${error.message}"), // Hata loglanabilir
      );

      // Kategorileri yükle (hem gelir hem gider)
      final expenseCategoriesResult =
          await _categoryRepository.getCategories(CategoryType.Expense);
      final incomeCategoriesResult =
          await _categoryRepository.getCategories(CategoryType.Income);

      final List<CategoryModel> allCategories = [];
      expenseCategoriesResult.when(
        success: (cats) => allCategories.addAll(cats),
        failure: (error) =>
            print("Error loading expense categories: ${error.message}"),
      );
      incomeCategoriesResult.when(
        success: (cats) => allCategories.addAll(cats),
        failure: (error) =>
            print("Error loading income categories: ${error.message}"),
      );
      // Ada göre sırala
      allCategories.sort((a, b) => a.name.compareTo(b.name));
      filterCategories.assignAll(allCategories);
    } catch (e) {
      print("Error loading filter options: $e");
      // Hata mesajı gösterilebilir
    }
  }

  /// İşlemleri API'den çeker (sayfalama ve filtreleme ile).
  /// [isInitialLoad] true ise mevcut listeyi temizler ve sayfayı sıfırlar.
  /// [loadMore] true ise sonraki sayfayı yükler.
  Future<void> fetchTransactions(
      {bool isInitialLoad = false, bool loadMore = false}) async {
    // Zaten yükleniyorsa veya daha fazla veri yoksa (loadMore için) işlemi durdur
    if ((isLoading.value && isInitialLoad) ||
        (isLoadingMore.value && loadMore) ||
        (!hasMoreData.value && loadMore)) return;

    if (isInitialLoad) {
      isLoading.value = true;
      _currentPage.value = 1;
      hasMoreData.value = true;
      transactionList.clear(); // İlk yüklemede listeyi temizle
    } else if (loadMore) {
      isLoadingMore.value = true;
      _currentPage.value++; // Sonraki sayfaya geç
    } else {
      isLoading.value = true; // Filtre değişikliği vb. için
      _currentPage.value = 1; // Filtre değişince sayfayı sıfırla
      hasMoreData.value = true;
      transactionList.clear();
    }
    errorMessage.value = ''; // Hata mesajını temizle

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
            hasMoreData.value =
                false; // Yeni veri gelmediyse daha fazla veri yoktur
          } else {
            transactionList
                .addAll(newTransactions); // Yeni işlemleri listeye ekle
            hasMoreData.value = newTransactions.length ==
                _pageSize; // Tam sayfa geldiyse daha fazla olabilir
          }
          print(
              '>>> Transactions fetched: ${newTransactions.length} items, Page: ${_currentPage.value}, HasMore: ${hasMoreData.value}');
        },
        failure: (error) {
          print('>>> Failed to fetch transactions: ${error.message}');
          errorMessage.value = error.message;
          hasMoreData.value =
              false; // Hata durumunda daha fazla veri olmadığını varsay
          _currentPage.value = _currentPage.value > 1
              ? _currentPage.value - 1
              : 1; // Hata olursa sayfayı geri al
        },
      );

      // Toplam gelir ve gider hesapla
      _calculateTotals();
    } catch (e) {
      print('>>> Fetch transactions unexpected error: $e');
      errorMessage.value = 'İşlemler yüklenirken beklenmedik bir hata oluştu.';
      hasMoreData.value = false;
      _currentPage.value = _currentPage.value > 1 ? _currentPage.value - 1 : 1;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Kaydırma olaylarını dinler ve listenin sonuna gelindiğinde daha fazla veri yükler.
  void _scrollListener() {
    // Scroll pozisyonu listenin sonuna yaklaştıysa ve yükleme yapılmıyorsa
    // ve daha fazla veri varsa, sonraki sayfayı yükle.
    if (scrollController.position.extentAfter < 200 && // Son 200 piksel kala
        !isLoadingMore.value &&
        hasMoreData.value) {
      fetchTransactions(loadMore: true);
    }
  }

  /// Seçilen filtreleri uygular ve işlemleri yeniden yükler.
  void applyFilters() {
    isLoading.value = true;
    transactionList.clear();
    _currentPage.value = 1;
    hasMoreData.value = true;
    fetchTransactions(isInitialLoad: false);
  }

  /// Tüm filtreleri temizler ve işlemleri yeniden yükler.
  Future<void> clearFilters() async {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedAccount.value = null;
    selectedCategory.value = null;
    selectedType.value = null;
    selectedQuickDate.value = null;
    // Filtreler temizlendiğinde ilk sayfayı yükle
    await fetchTransactions(isInitialLoad: true);
  }

  /// Tarih aralığı seçimi için dialog gösterir.
  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      // 5 yıl öncesine kadar
      lastDate: DateTime.now().add(const Duration(days: 1)),
      // Yarına kadar
      initialDateRange:
          selectedStartDate.value != null && selectedEndDate.value != null
              ? DateTimeRange(
                  start: selectedStartDate.value!, end: selectedEndDate.value!)
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
            // textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(primary: AppColors.primary)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedStartDate.value = picked.start;
      // Bitiş tarihine günün sonunu ekleyerek tüm günü kapsamasını sağla (opsiyonel)
      selectedEndDate.value = DateTime(
          picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      applyFilters(); // Filtreyi uygula
    }
  }

  /// Hesap filtresini ayarlar.
  void selectAccountFilter(AccountModel? account) {
    selectedAccount.value = account;
    applyFilters();
  }

  /// Kategori filtresini ayarlar.
  void selectCategoryFilter(CategoryModel? category) {
    selectedCategory.value = category;
    applyFilters();
  }

  /// Gelir/Gider filtresini ayarlar.
  void selectTypeFilter(CategoryType? type) {
    selectedType.value = type;
    applyFilters();
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

    isLoading.value = true; // Silme işlemi sırasında indicator gösterilebilir
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
      isLoading.value = false;
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

  // Sıralama kriterini ayarla
  void setSortingCriteria(String criteria) {
    sortCriteria.value = criteria;
    applyFilters();
  }

  // Hızlı tarih filtresi ayarla
  void setQuickDateFilter(String? period) {
    selectedQuickDate.value = period; // Seçilen değeri güncelle

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
      default:
        selectedStartDate.value = null;
        selectedEndDate.value = null;
        break;
    }

    applyFilters();
  }

  /// Takvimden seçilen tarih aralığını ayarlar.
  void selectDateRangeFromCalendar(DateTime startDate, DateTime endDate) {
    selectedStartDate.value = startDate;
    selectedEndDate.value = endDate;
    applyFilters();
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
}
