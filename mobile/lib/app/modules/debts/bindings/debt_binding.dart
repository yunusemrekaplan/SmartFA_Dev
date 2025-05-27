import 'package:get/get.dart';
import 'package:mobile/app/data/repositories/debt_repository_impl.dart';
import 'package:mobile/app/domain/repositories/debt_repository.dart';
import 'package:mobile/app/modules/debts/controllers/debt_controller.dart';

class DebtBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DebtController>(
      () => DebtController(
        Get.find<IDebtRepository>(),
      ),
    );
  }
}
