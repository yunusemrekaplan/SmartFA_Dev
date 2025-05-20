import 'dart:developer';

import 'package:get/get.dart';
import 'package:mobile/app/core/services/navigation/i_navigation_service.dart';
import 'package:mobile/app/core/services/page/i_page_service.dart';

/// Sayfa işlemlerini yöneten servis
class PageService extends GetxService implements IPageService {
  final INavigationService _navigationService;

  PageService(this._navigationService);

  @override
  Future<T?> toNamed<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) async {
    log('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');

    return _navigationService.toNamed<T>(
      page,
      arguments: arguments,
      parameters: parameters,
    );
  }

  @override
  void closeLastPage() {
    _navigationService.closeLastPage();
  }

  @override
  void closeAllPages() {
    _navigationService.closeAllPages();
  }

  @override
  void closeUntilPage(String pageName) {
    while (_navigationService.activePages.isNotEmpty &&
        _navigationService.activePages.last != pageName) {
      closeLastPage();
    }
  }

  @override
  void closeUntilRoot() {
    closeAllPages();
  }

  @override
  void backToPage(String pageName) {
    closeUntilPage(pageName);
  }

  @override
  void offAllNamed(String page) {
    Get.offAllNamed(page);
    _navigationService.activePages.clear();
    _navigationService.activePages.add(page);
  }

  @override
  void offAndToNamed(String page) {
    Get.offAndToNamed(page);
    if (_navigationService.activePages.isNotEmpty) {
      _navigationService.activePages.removeLast();
    }
    _navigationService.activePages.add(page);
  }
}
