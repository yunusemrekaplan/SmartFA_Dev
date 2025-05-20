import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/core/services/navigation/i_navigation_service.dart';

/// Uygulama genelinde navigasyon işlemlerini yöneten servis
class NavigationService extends GetxService implements INavigationService {
  // Aktif snackbar'ları tutan liste
  final RxList<SnackbarController> _activeSnackbars =
      <SnackbarController>[].obs;

  // Aktif dialogları tutan liste
  final RxList<Widget> _activeDialogs = <Widget>[].obs;

  // Aktif sayfaları tutan liste
  final RxList<String> _activePages = <String>[].obs;

  @override
  List<SnackbarController> get activeSnackbars => _activeSnackbars;

  @override
  List<Widget> get activeDialogs => _activeDialogs;

  @override
  List<String> get activePages => _activePages;

  @override
  void showSnackbar({
    required String title,
    required String message,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    final snackbar = GetSnackBar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      duration: duration,
      snackPosition: position,
    );

    final controller = Get.showSnackbar(snackbar);
    _activeSnackbars.add(controller);

    Future.delayed(duration, () {
      _activeSnackbars.remove(controller);
    });
  }

  @override
  Future<T?> showDialog<T>({
    required Widget dialog,
    bool barrierDismissible = true,
  }) async {
    _activeDialogs.add(dialog);

    final result = await Get.dialog<T>(
      dialog,
      barrierDismissible: barrierDismissible,
    );

    _activeDialogs.remove(dialog);
    return result;
  }

  @override
  Future<T?> toNamed<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) async {
    _activePages.add(page);

    final result = await Get.toNamed<T>(
      page,
      arguments: arguments,
      parameters: parameters,
    );

    _activePages.remove(page);
    return result;
  }

  @override
  void closeLastSnackbar() {
    if (_activeSnackbars.isNotEmpty) {
      final snackbar = _activeSnackbars.last;
      snackbar.close();
      _activeSnackbars.removeLast();
    }
  }

  @override
  void closeLastDialog() {
    if (_activeDialogs.isNotEmpty) {
      Get.back(closeOverlays: false);
      _activeDialogs.removeLast();
    }
  }

  @override
  void closeLastPage() {
    if (_activePages.isNotEmpty) {
      // Sadece sayfayı kapat, diğer overlay'leri etkileme
      Navigator.of(Get.context!).pop();
      _activePages.removeLast();
    }
  }

  @override
  void closeAllSnackbars() {
    while (_activeSnackbars.isNotEmpty) {
    }
      closeLastSnackbar();
    }

  @override
  void closeAllDialogs() {
    while (_activeDialogs.isNotEmpty) {
      closeLastDialog();
    }
  }

  @override
  void closeAllPages() {
    while (_activePages.isNotEmpty) {
      closeLastPage();
    }
  }

  @override
  void closeAll() {
    closeAllSnackbars();
    closeAllDialogs();
    closeAllPages();
  }
}
