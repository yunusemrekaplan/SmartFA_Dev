import 'package:get/get.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Hesaplar modülündeki navigasyon işlemlerini yöneten servis
/// SRP (Single Responsibility Principle) - Navigasyon işlemleri tek bir sınıfta toplanır
class AccountNavigationService {
  /// Yeni hesap ekleme ekranına geçiş yapar
  Future<dynamic> goToAddAccount() async {
    return await Get.toNamed(AppRoutes.ADD_EDIT_ACCOUNT);
  }

  /// Hesap düzenleme ekranına geçiş yapar
  Future<dynamic> goToEditAccount(AccountModel account) async {
    return await Get.toNamed(AppRoutes.ADD_EDIT_ACCOUNT, arguments: account);
  }

  /// Önceki ekrana dönüş
  void goBack({dynamic result}) {
    Get.back(result: result);
  }
}
