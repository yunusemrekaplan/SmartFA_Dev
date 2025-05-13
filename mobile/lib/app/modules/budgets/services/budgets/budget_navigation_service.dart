import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Bütçe ekranında sayfa yönlendirme işlemlerini yöneten servis sınıfı
class BudgetNavigationService {
  /// Yeni bütçe ekleme ekranına yönlendirir.
  Future<dynamic>? goToAddBudget() {
    return Get.toNamed(AppRoutes.ADD_EDIT_BUDGET);
  }

  /// Bütçe düzenleme ekranına yönlendirir.
  Future<dynamic>? goToEditBudget(BudgetModel budget) {
    return Get.toNamed(AppRoutes.ADD_EDIT_BUDGET, arguments: budget);
  }
}
