import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'add_edit_account_controller.dart';

class AddEditAccountBinding extends Bindings {
  @override
  void dependencies() {
    // Controller bağımlılıklarını kaydeder
    Get.lazyPut<AddEditAccountController>(
      () => AddEditAccountController(
        accountRepository: Get.find<IAccountRepository>(),
      ),
    );
  }
}
