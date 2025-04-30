import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/dashboard/dashboard_controller.dart';
import 'package:mobile/app/modules/transactions/transactions_controller.dart';

// Controller import
import 'home_controller.dart';

// Sekmelerde gösterilecek ekranları import et
import '../dashboard/dashboard_screen.dart';
import '../accounts/accounts_screen.dart';
import '../transactions/transactions_screen.dart';
import '../settings/settings_screen.dart';

// Rota importu (FAB için)
import '../../navigation/app_routes.dart';

/// Ana ekran widget'ı, alt navigasyon çubuğunu ve sekmeleri içerir.
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  // Alt navigasyon çubuğuna karşılık gelen GERÇEK ekranların listesi
  final List<Widget> _screens = const [
    DashboardScreen(), // Index 0
    AccountsScreen(), // Index 1
    TransactionsScreen(), // Index 2
    SettingsScreen(), // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    // İlgili Binding'lerin (HomeBinding, DashboardBinding, AccountsBinding vb.)
    // app_pages.dart içinde doğru şekilde tanımlandığından emin olun.
    // GetView kullandığımız için controller'a doğrudan erişebiliriz.

    return Scaffold(
      // Seçili sekmeye göre body'yi değiştirmek için Obx ve IndexedStack
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value, // HomeController'daki index'i dinle
            children: _screens, // Gösterilecek GERÇEK ekranların listesi
          )),

      // Floating Action Button (Yeni İşlem Ekle)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni işlem ekleme ekranına yönlendir
          Get.toNamed(AppRoutes.ADD_EDIT_TRANSACTION)?.then((result) {
            // İşlem eklendikten sonra belki Dashboard veya İşlemler listesi yenilenebilir
            if (result == true) {
              // İlgili controller'ı bulup yenileme metodunu çağır
              try {
                final transactionsController = Get.find<TransactionsController>();
                transactionsController.fetchTransactions(isInitialLoad: true);
              } catch (e) {
                /* Controller henüz oluşturulmamış olabilir */
              }
              try {
                final dashboardController = Get.find<DashboardController>();
                dashboardController.refreshData();
              } catch (e) {
                /* Controller henüz oluşturulmamış olabilir */
              }
            }
          });
        },
        tooltip: 'Yeni İşlem',
        child: const Icon(Icons.add),
        // Tema renklerini kullanır
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Ortala

      // BottomAppBar (FAB'ı ortalamak için)
      // BottomNavigationBar yerine bunu kullanın
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // FAB için çentik
        notchMargin: 6.0, // Çentik boşluğu
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // İkonları yay
          children: <Widget>[
            _buildBottomNavItem(icon: Icons.dashboard_outlined, index: 0, label: 'Dashboard'),
            _buildBottomNavItem(
                icon: Icons.account_balance_wallet_outlined, index: 1, label: 'Hesaplar'),
            const SizedBox(width: 40), // FAB için boşluk bırak
            _buildBottomNavItem(icon: Icons.swap_horiz, index: 2, label: 'İşlemler'),
            _buildBottomNavItem(icon: Icons.settings_outlined, index: 3, label: 'Ayarlar'),
          ],
        ),
      ),
    );
  }

  /// BottomAppBar için tıklanabilir ikon oluşturan yardımcı widget.
  Widget _buildBottomNavItem({required IconData icon, required int index, required String label}) {
    return Obx(() => IconButton(
          tooltip: label,
          icon: Icon(
            icon,
            color: controller.selectedIndex.value == index
                ? Theme.of(Get.context!).colorScheme.primary // Seçili renk
                : Colors.grey.shade600, // Seçili olmayan renk
          ),
          // Eğer ikon seçiliyse rengini değiştir
          // color: controller.selectedIndex.value == index ? Theme.of(Get.context!).colorScheme.primary : Colors.grey,
          onPressed: () => controller.changeTabIndex(index),
        ));
  }
}
