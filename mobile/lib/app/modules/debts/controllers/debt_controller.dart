import 'package:get/get.dart';
import 'package:mobile/app/domain/models/request/debt_request_models.dart';
import 'package:mobile/app/domain/models/response/debt_response_model.dart';
import 'package:mobile/app/domain/repositories/debt_repository.dart';

class DebtController extends GetxController {
  final IDebtRepository _debtRepository;

  final RxList<DebtModel> debts = <DebtModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  DebtController(this._debtRepository);

  @override
  void onInit() {
    super.onInit();
    loadDebts();
  }

  Future<void> loadDebts() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _debtRepository.getUserActiveDebts();
    result.when(
      success: (data) {
        debts.value = data;
      },
      failure: (error) {
        errorMessage.value = error.message;
      },
    );

    isLoading.value = false;
  }

  Future<bool> createDebt(CreateDebtRequestModel debtData) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _debtRepository.createDebt(debtData);
    bool success = false;

    result.when(
      success: (data) {
        debts.add(data);
        success = true;
      },
      failure: (error) {
        errorMessage.value = error.message;
      },
    );

    isLoading.value = false;
    return success;
  }

  Future<bool> updateDebt(int debtId, UpdateDebtRequestModel debtData) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _debtRepository.updateDebt(debtId, debtData);
    bool success = false;

    result.when(
      success: (_) {
        final index = debts.indexWhere((debt) => debt.id == debtId);
        if (index != -1) {
          final updatedDebt = debts[index];
          debts[index] = DebtModel(
            id: updatedDebt.id,
            name: debtData.name,
            lenderName: debtData.lenderName,
            totalAmount: updatedDebt.totalAmount,
            remainingAmount: updatedDebt.remainingAmount,
            currency: updatedDebt.currency,
            isPaidOff: updatedDebt.isPaidOff,
          );
        }
        success = true;
      },
      failure: (error) {
        errorMessage.value = error.message;
      },
    );

    isLoading.value = false;
    return success;
  }

  Future<bool> deleteDebt(int debtId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _debtRepository.deleteDebt(debtId);
    bool success = false;

    result.when(
      success: (_) {
        debts.removeWhere((debt) => debt.id == debtId);
        success = true;
      },
      failure: (error) {
        errorMessage.value = error.message;
      },
    );

    isLoading.value = false;
    return success;
  }
}
