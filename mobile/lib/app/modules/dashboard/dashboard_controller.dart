import 'package:get/get.dart';
import 'package:mobile/app/data/models/request/transaction_request_models.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/utils/result.dart';

/// Dashboard ekranının state'ini ve iş mantığını yöneten GetX controller.
class DashboardController extends GetxController {
  // Repository'leri inject et (Binding üzerinden)
  final IAccountRepository _accountRepository;
  final ITransactionRepository _transactionRepository;
  final IBudgetRepository _budgetRepository;

  // final IDebtRepository _debtRepository; // Gerekirse

  DashboardController({
    required IAccountRepository accountRepository,
    required ITransactionRepository transactionRepository,
    required IBudgetRepository budgetRepository,
    // required IDebtRepository debtRepository,
  })  : _accountRepository = accountRepository,
        _transactionRepository = transactionRepository,
        _budgetRepository = budgetRepository
  // _debtRepository = debtRepository
  ;

  // --- State Değişkenleri ---

  // Yüklenme durumu
  final RxBool isLoading = true.obs; // Başlangıçta yükleniyor

  // Hata durumu
  final RxString errorMessage = ''.obs;

  // Dashboard Verileri
  final RxDouble totalBalance = 0.0.obs; // Toplam bakiye
  final RxList<TransactionModel> recentTransactions = <TransactionModel>[].obs; // Son işlemler
  final RxList<BudgetModel> budgetSummaries = <BudgetModel>[].obs; // Bütçe özetleri
  // final RxDouble totalDebt = 0.0.obs; // Toplam borç (gerekirse)

  // --- Lifecycle Metotları ---

  @override
  void onInit() {
    super.onInit();
    print('>>> DashboardController onInit called');
    // Controller ilk oluşturulduğunda verileri çek
    fetchDashboardData();
  }

  // --- Metotlar ---

  /// Dashboard için gerekli verileri API'den çeker ve state'i günceller.
  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';
    bool hasError = false; // Herhangi bir API çağrısında hata olursa işaretle

    try {
      // Verileri paralel çekmek için Future.wait kullanılabilir
      final results = await Future.wait([
        _fetchTotalBalance(), // Hesapları çekip bakiyeyi hesapla
        _fetchRecentTransactions(), // Son işlemleri çek
        _fetchBudgetSummaries(), // Bu ayın bütçelerini çek
        // _fetchTotalDebt(), // Gerekirse borçları çek
      ]);

      // Sonuçları işle
      final balanceResult = results[0] as Result<double, ApiException>;
      final transactionsResult = results[1] as Result<List<TransactionModel>, ApiException>;
      final budgetsResult = results[2] as Result<List<BudgetModel>, ApiException>;
      // final debtResult = results[3] as Result<double, ApiException>; // Gerekirse

      // Toplam Bakiye
      balanceResult.when(
        success: (balance) => totalBalance.value = balance,
        failure: (error) {
          errorMessage.value += 'Bakiye yüklenemedi: ${error.message}\n';
          hasError = true;
        },
      );

      // Son İşlemler
      transactionsResult.when(
        success: (transactions) => recentTransactions.assignAll(transactions),
        failure: (error) {
          errorMessage.value += 'Son işlemler yüklenemedi: ${error.message}\n';
          hasError = true;
        },
      );

      // Bütçe Özetleri
      budgetsResult.when(
        success: (budgets) => budgetSummaries.assignAll(budgets),
        failure: (error) {
          errorMessage.value += 'Bütçeler yüklenemedi: ${error.message}\n';
          hasError = true;
        },
      );

      // Toplam Borç (Gerekirse)
      // debtResult.when(
      //   success: (debt) => totalDebt.value = debt,
      //   failure: (error) {
      //     errorMessage.value += 'Borçlar yüklenemedi: ${error.message}\n';
      //     hasError = true;
      //   },
      // );

      if (hasError) {
        print('>>> DashboardController: Errors occurred during data fetch.');
        // Hata mesajını Snackbar ile gösterebiliriz
        // Get.snackbar('Hata', 'Bazı veriler yüklenirken sorun oluştu.', snackPosition: SnackPosition.BOTTOM);
      } else {
        print('>>> DashboardController: Data fetch successful.');
      }
    } catch (e) {
      // Future.wait veya diğer beklenmedik hatalar
      print('>>> DashboardController fetchDashboardData Unexpected Error: $e');
      errorMessage.value = 'Dashboard verileri yüklenirken beklenmedik bir hata oluştu.';
      hasError = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Toplam bakiyeyi hesaplamak için hesapları çeker.
  Future<Result<double, ApiException>> _fetchTotalBalance() async {
    final result = await _accountRepository.getUserAccounts();
    return result.when(
      success: (accounts) {
        // Kredi kartı borçlarını düşerek veya dahil ederek hesapla (varsayım: dahil)
        double balance = accounts.fold(0.0, (sum, account) => sum + account.currentBalance);
        return Success(balance);
      },
      failure: (error) => Failure(error), // Hatayı doğrudan ilet
    );
  }

  /// Son birkaç işlemi (örn: son 5 işlem) çeker.
  Future<Result<List<TransactionModel>, ApiException>> _fetchRecentTransactions() async {
    // Son 5 işlemi çekmek için filtre oluştur (sayfa 1, boyut 5)
    final filter = TransactionFilterDto(pageNumber: 1, pageSize: 5);
    final result = await _transactionRepository.getUserTransactions(filter);
    // Başarı durumunda listeyi döndür, hata durumunda hatayı ilet
    return result.when(
      success: (transactions) => Success(transactions),
      failure: (error) => Failure(error),
    );
  }

  /// Mevcut ayın bütçe özetlerini çeker.
  Future<Result<List<BudgetModel>, ApiException>> _fetchBudgetSummaries() async {
    final now = DateTime.now();
    final result = await _budgetRepository.getUserBudgetsByPeriod(now.year, now.month);
    // Başarı durumunda listeyi döndür, hata durumunda hatayı ilet
    return result.when(
      success: (budgets) => Success(budgets),
      failure: (error) => Failure(error),
    );
  }

  /// Toplam borcu hesaplamak için borçları çeker (opsiyonel).
  // Future<Result<double, ApiException>> _fetchTotalDebt() async {
  //   final result = await _debtRepository.getUserActiveDebts();
  //   return result.when(
  //     success: (debts) {
  //       double total = debts.fold(0.0, (sum, debt) => sum + debt.remainingAmount);
  //       return Result.success(total);
  //     },
  //     failure: (error) => Result.failure(error),
  //   );
  // }

  /// Verileri manuel olarak yenilemek için metot (Pull-to-refresh vb.).
  Future<void> refreshData() async {
    await fetchDashboardData();
  }
}
