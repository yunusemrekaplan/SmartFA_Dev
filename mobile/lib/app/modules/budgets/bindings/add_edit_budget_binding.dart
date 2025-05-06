import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/modules/budgets/controllers/add_edit_budget_controller.dart';

class AddEditBudgetBinding extends Bindings {
  @override
  void dependencies() {
    // Data ve Repository katmanı bağımlılıkları BudgetsBinding'den gelecek
    // Kategori seçimi için kategori repository'sine de ihtiyaç var

    // Controller bağımlılığı
    Get.lazyPut<AddEditBudgetController>(
      () => AddEditBudgetController(
        Get.find<IBudgetRepository>(),
        Get.find<ICategoryRepository>(),
      ),
    );
  }
}
