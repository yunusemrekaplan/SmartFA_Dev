import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/home/home_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Ana sayfanın modern Material 3 AppBar'ı için özelleştirilmiş widget
class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;

  const CustomHomeAppBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Obx(() => _buildTitle(context)),
      actions: [
        // Bildirim butonu
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Bildirimler',
          onPressed: () {
            // TODO: Bildirimler sayfasına yönlendir
            _showNotImplementedMessage(
                context, 'Bildirimler henüz yapım aşamasında');
          },
        ),
        // Yenile butonu
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Yenile',
          onPressed: () {
            _refreshCurrentTab(context);
          },
        ),
      ],
    );
  }

  /// Seçili tab'e göre başlık oluşturur
  Widget _buildTitle(BuildContext context) {
    Widget title;

    switch (controller.selectedIndex.value) {
      case 0:
        title = _buildTitleWithIcon(
          context: context,
          text: 'Özet',
          icon: Icons.dashboard_rounded,
        );
        break;
      case 1:
        title = _buildTitleWithIcon(
          context: context,
          text: 'Hesaplar',
          icon: Icons.account_balance_wallet_rounded,
        );
        break;
      case 2:
        title = _buildTitleWithIcon(
          context: context,
          text: 'İşlemler',
          icon: Icons.sync_alt_rounded,
        );
        break;
      case 3:
        title = _buildTitleWithIcon(
          context: context,
          text: 'Bütçeler',
          icon: Icons.pie_chart_rounded,
        );
        break;
      default:
        title = const Text('SmartFA');
    }

    return title;
  }

  /// İkon ve metinden oluşan başlık oluşturur
  Widget _buildTitleWithIcon(
      {required BuildContext context,
      required String text,
      required IconData icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 22,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  /// Geçerli sekmeyi yeniler
  void _refreshCurrentTab(BuildContext context) {
    final index = controller.selectedIndex.value;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getTabName(index)} veriler yenileniyor...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    switch (index) {
      case 0:
        controller.dashboardController.refreshData();
        break;
      case 1:
        controller.accountsController.fetchAccounts();
        break;
      case 2:
        controller.transactionsController
            .fetchTransactions(isInitialLoad: false);
        break;
      case 3:
        controller.budgetsController.refreshBudgets();
        break;
    }
  }

  /// Index'e göre tab adını döndürür
  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Özet';
      case 1:
        return 'Hesaplar';
      case 2:
        return 'İşlemler';
      case 3:
        return 'Bütçeler';
      default:
        return '';
    }
  }

  /// Uygulanmamış özellikler için bildirim gösterir
  void _showNotImplementedMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
