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
    return Scaffold(
      // Seçili sekmeye göre body'yi değiştirmek için Obx ve PageView
      body: PageView(
        physics:
            const NeverScrollableScrollPhysics(), // Sayfa kaydırmayı devre dışı bırak
        controller: controller.pageController,
        onPageChanged: controller.changeTabIndex,
        children: const [
          DashboardScreen(), // Index 0
          AccountsScreen(), // Index 1
          TransactionsScreen(), // Index 2
          BudgetsScreen(), // Index 3
        ],
      ),

      // Drawer menüsü
      drawer: const AppDrawer(),

      // Hızlı işlemler için FAB
      floatingActionButton: _buildFAB(context),

      // FAB konum ayarı
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Alt navigasyon çubuğu
      bottomNavigationBar: CustomBottomBar(controller: controller),
    );
  }

  /// Seçili sekmeye göre FAB oluşturur
  Widget _buildFAB(BuildContext context) {
    return Obx(() {
      // FAB renkleri ve gölge efekti
      return FloatingActionButton(
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: _getFABTooltip(),
        onPressed: () => _handleFABPressed(),
        child: const Icon(Icons.add, size: 28),
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
