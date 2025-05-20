import 'package:get/get.dart';
import 'package:mobile/app/core/services/page/i_page_service.dart';
import 'package:mobile/app/domain/models/response/transaction_response_model.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// İşlem ekranında sayfa yönlendirme işlemlerini yöneten servis sınıfı
class TransactionNavigationService {
  final _pageService = Get.find<IPageService>();

  /// İşlem detay sayfasına yönlendirir
  Future<dynamic>? goToTransactionDetail(TransactionModel transaction) {
    return _pageService.toNamed(AppRoutes.TRANSACTION_DETAIL, arguments: transaction);
  }

  /// İşlem ekleme sayfasına yönlendirir
  Future<dynamic>? goToAddTransaction() {
    return _pageService.toNamed(AppRoutes.ADD_EDIT_TRANSACTION);
  }

  /// İşlem düzenleme sayfasına yönlendirir
  Future<dynamic>? goToEditTransaction(TransactionModel transaction) {
    return _pageService.toNamed(AppRoutes.ADD_EDIT_TRANSACTION, arguments: transaction);
  }
}
