import 'package:get/get.dart';
import 'package:mobile/app/core/services/snackbar/i_snackbar_service.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/request/transaction_request_models.dart';
import 'package:mobile/app/domain/models/response/transaction_response_model.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/utils/error_handler/error_handler.dart';

/// İşlem verilerini yönetmekten sorumlu servis sınıfı
class TransactionDataService {
  final ITransactionRepository _transactionRepository;
  final _errorHandler = ErrorHandler();
  final _snackbarService = Get.find<ISnackbarService>();

  // Yüklenme durumu
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  // Hata durumu
  final RxString errorMessage = ''.obs;

  // İşlem Listesi
  final RxList<TransactionModel> transactionList = <TransactionModel>[].obs;

  // Sayfalama için
  final RxInt currentPage = 1.obs;
  final int pageSize = 20;
  final RxBool hasMoreData = true.obs;

  // Toplam değerler
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;

  TransactionDataService(this._transactionRepository);

  /// İşlemleri API'den çeker
  Future<bool> fetchTransactions(TransactionFilterDto filter) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Sayfalama bilgisini sıfırla
      currentPage.value = 1;
      hasMoreData.value = true;

      // Mevcut listeyi temizle
      transactionList.clear();

      // Filtre değiştiğinde sayfa 1'den başla
      final result = await _transactionRepository.getUserTransactions(
        filter.copyWith(pageNumber: 1),
      );

      return result.when(
        success: (transactions) {
          transactionList.assignAll(transactions);
          hasMoreData.value = transactions.length == pageSize;
          _calculateTotals();
          print(
              '>>> Transactions fetched successfully: ${transactions.length} transactions.');
          return true;
        },
        failure: (error) {
          print('>>> Failed to fetch transactions: ${error.message}');
          errorMessage.value = error.message;
          return false;
        },
      );
    } catch (e) {
      print('>>> Unexpected error while fetching transactions: $e');
      errorMessage.value = 'Beklenmeyen bir hata oluştu';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Daha fazla işlem yükler (sayfalama için)
  Future<bool> loadMoreTransactions(TransactionFilterDto filter) async {
    if (isLoadingMore.value || !hasMoreData.value) return false;

    print('>>> Loading more transactions...');

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      // Eğer sayfa 1'den büyükse ve liste boşsa, sayfayı 1'e çek
      if (currentPage.value > 1 && transactionList.isEmpty) {
        currentPage.value = 1;
      }

      final result = await _transactionRepository.getUserTransactions(
        filter.copyWith(pageNumber: currentPage.value),
      );

      return result.when(
        success: (transactions) {
          if (transactions.isEmpty) {
            hasMoreData.value = false;
            return false;
          }

          transactionList.addAll(transactions);
          hasMoreData.value = transactions.length == pageSize;
          _calculateTotals();
          return true;
        },
        failure: (error) {
          print('>>> Failed to load more transactions: ${error.message}');
          errorMessage.value = error.message;
          return false;
        },
      );
    } catch (e) {
      print('>>> Unexpected error while loading more transactions: $e');
      errorMessage.value = 'Beklenmeyen bir hata oluştu';
      return false;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// İşlem siler
  Future<bool> deleteTransaction(int transactionId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result =
          await _transactionRepository.deleteTransaction(transactionId);

      return result.when(
        success: (_) {
          transactionList.removeWhere((t) => t.id == transactionId);
          _calculateTotals();
          _snackbarService.showSuccess(
            message: 'İşlem başarıyla silindi.',
            title: 'Başarılı',
          );
          return true;
        },
        failure: (error) {
          _errorHandler.handleError(
            error,
            message: error.message,
            customTitle: 'İşlem Silinemedi',
          );
          return false;
        },
      );
    } catch (e) {
      print('>>> Unexpected error while deleting transaction: $e');
      errorMessage.value = 'İşlem silinirken beklenmedik bir hata oluştu';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Listeyi temizler ve sayfalamayı sıfırlar
  void reset() {
    transactionList.clear();
    currentPage.value = 1;
    hasMoreData.value = true;
    errorMessage.value = '';
    totalIncome.value = 0;
    totalExpense.value = 0;
  }

  /// Toplam gelir ve giderleri hesaplar
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
