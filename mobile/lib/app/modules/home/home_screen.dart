import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/theme/app_colors.dart';

// Controller import
import 'home_controller.dart';

// Sekmelerde gösterilecek ekranları import et
import '../dashboard/dashboard_screen.dart';
import '../accounts/views/accounts_screen.dart';
import '../transactions/views/transactions_screen.dart';
import '../budgets/views/budgets_screen.dart';

// Rota importu (FAB için)
import '../../navigation/app_routes.dart';

// Özelleştirilmiş bileşenler
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_bottom_bar.dart';

/// Ana ekran widget'ı, alt navigasyon çubuğunu ve sekmeleri içerir.
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        extendBody: false,
        // FAB ve bottom bar için body'yi uzat

        // Seçili sekmeye göre body'yi değiştirmek için PageView
        body: PageView(
          physics: const NeverScrollableScrollPhysics(), // Sayfa kaydırmayı devre dışı bırak
          controller: controller.pageController,
          onPageChanged: controller.changeTabIndex,
          children: [
            _buildAnimatedPage(const DashboardScreen(), 0), // Index 0
            _buildAnimatedPage(const AccountsScreen(), 1), // Index 1
            _buildAnimatedPage(const TransactionsScreen(), 2), // Index 2
            _buildAnimatedPage(const BudgetsScreen(), 3), // Index 3
          ],
        ),

        // Drawer menüsü
        drawer: const AppDrawer(),

        // Hızlı işlemler için FAB
        floatingActionButton: _buildFAB(context),

        // FAB konum ayarı
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // Alt navigasyon çubuğu
        bottomNavigationBar: AnimatedOpacity(
          opacity: controller.isChangingTab.value ? 0.8 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: CustomBottomBar(controller: controller),
        ),
      );
    });
  }

  /// Sekme sayfalarını animasyonlu olarak oluşturur
  Widget _buildAnimatedPage(Widget page, int index) {
    return Obx(() {
      final isActive = controller.selectedIndex.value == index;

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isActive ? 1.0 : 0.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: isActive ? 1.0 : 0.92,
          child: page,
        ),
      );
    });
  }

  /// Seçili sekmeye göre FAB oluşturur
  Widget _buildFAB(BuildContext context) {
    return Obx(() {
      // FAB içeriği ve özellikleri
      IconData fabIcon;
      String fabTooltip = _getFABTooltip();
      Color fabColor;

      switch (controller.selectedIndex.value) {
        case 0: // Dashboard
          fabIcon = Icons.add_chart;
          fabColor = AppColors.primary;
          break;
        case 1: // Accounts
          fabIcon = Icons.account_balance_wallet_outlined;
          fabColor = AppColors.primary;
          break;
        case 2: // Transactions
          fabIcon = Icons.receipt_long_outlined;
          fabColor = AppColors.primary;
          break;
        case 3: // Budgets
          fabIcon = Icons.pie_chart_outline;
          fabColor = AppColors.primary;
          break;
        default:
          fabIcon = Icons.add;
          fabColor = AppColors.primary;
      }

      return AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: controller.isChangingTab.value ? 0.8 : 1.0,
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 300),
          turns: controller.isChangingTab.value ? 0.05 : 0,
          child: FloatingActionButton(
            elevation: 8,
            backgroundColor: fabColor,
            foregroundColor: Colors.white,
            tooltip: fabTooltip,
            onPressed: _handleFABPressed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              fabIcon,
              size: 28,
            ),
          ),
        ),
      );
    });
  }

  /// Seçili sekmeye göre FAB tooltip metni
  String _getFABTooltip() {
    switch (controller.selectedIndex.value) {
      case 0:
        return 'Yeni İşlem Ekle';
      case 1:
        return 'Yeni Hesap Ekle';
      case 2:
        return 'Yeni İşlem Ekle';
      case 3:
        return 'Yeni Bütçe Ekle';
      default:
        return 'Ekle';
    }
  }

  /// Seçili sekmeye göre FAB tıklama işlemi
  void _handleFABPressed() {
    switch (controller.selectedIndex.value) {
      case 0: // Dashboard
      case 2: // Transactions
        Get.toNamed(AppRoutes.ADD_EDIT_TRANSACTION);
        break;
      case 1: // Accounts
        Get.toNamed(AppRoutes.ADD_EDIT_ACCOUNT);
        break;
      case 3: // Budgets
        Get.toNamed(AppRoutes.ADD_EDIT_BUDGET);
        break;
    }
  }
}
