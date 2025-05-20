import 'package:get/get.dart';
import 'package:mobile/app/core/services/navigation/i_navigation_service.dart';
import 'package:mobile/app/core/services/navigation/navigation_service.dart';
import 'package:mobile/app/core/services/dialog/i_dialog_service.dart';
import 'package:mobile/app/core/services/dialog/dialog_service.dart';
import 'package:mobile/app/core/services/snackbar/i_snackbar_service.dart';
import 'package:mobile/app/core/services/snackbar/snackbar_service.dart';
import 'package:mobile/app/core/services/page/i_page_service.dart';
import 'package:mobile/app/core/services/page/page_service.dart';

/// Uygulama servislerinin bağımlılık enjeksiyonunu yapan sınıf
class ServiceBindings extends Bindings {
  @override
  void dependencies() {
    // Navigation Service
    Get.put<INavigationService>(
      NavigationService(),
      permanent: true,
    );

    // Dialog Service
    Get.put<IDialogService>(
      DialogService(Get.find()),
      permanent: true,
    );

    // Snackbar Service
    Get.put<ISnackbarService>(
      SnackbarService(Get.find()),
      permanent: true,
    );

    // Page Service
    Get.put<IPageService>(
      PageService(Get.find()),
      permanent: true,
    );
  }
}
