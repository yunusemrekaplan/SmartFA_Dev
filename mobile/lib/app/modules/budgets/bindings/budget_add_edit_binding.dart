import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/modules/budgets/controllers/budget_add_edit_controller.dart';

class BudgetAddEditBinding extends Bindings {
  @override
  void dependencies() {
    // Data ve Repository katmanı bağımlılıkları BudgetsBinding'den gelecek
    // Kategori seçimi için kategori repository'sine de ihtiyaç var

    // Controller bağımlılığı
    Get.lazyPut<BudgetAddEditController>(
      () => BudgetAddEditController(
        Get.find<IBudgetRepository>(),
        Get.find<ICategoryRepository>(),
      ),
    );
  }
}
