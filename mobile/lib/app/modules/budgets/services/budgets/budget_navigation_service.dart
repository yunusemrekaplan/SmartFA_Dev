import 'package:get/get.dart';
import 'package:mobile/app/core/services/page/i_page_service.dart';
import 'package:mobile/app/domain/models/response/budget_response_model.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Bütçe ekranında sayfa yönlendirme işlemlerini yöneten servis sınıfı
class BudgetNavigationService {
  final _pageService = Get.find<IPageService>();

  /// Yeni bütçe ekleme ekranına yönlendirir.
  Future<dynamic>? goToAddBudget() {
    return _pageService.toNamed(AppRoutes.ADD_EDIT_BUDGET);
  }

  /// Bütçe düzenleme ekranına yönlendirir.
  Future<dynamic>? goToEditBudget(BudgetModel budget) {
    return _pageService.toNamed(AppRoutes.ADD_EDIT_BUDGET, arguments: budget);
  }
}
