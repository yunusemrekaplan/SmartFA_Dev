import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/accounts/controllers/accounts_controller.dart';
import 'package:mobile/app/modules/accounts/widgets/accounts_content.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/widgets/empty_state_view.dart';
import 'package:mobile/app/widgets/error_view.dart';
import 'package:mobile/app/widgets/custom_app_bar.dart';

/// Kullanıcının hesaplarını listeleyen modern ekran.
/// SRP (Single Responsibility Principle) - Hesaplar ekranı gösterimi için temel container
/// OCP (Open-Closed Principle) - Yeni durum eklemek istediğimizde bu sınıfı değiştirmeden Widget kompozisyonu ile yapabiliriz
class AccountsScreen extends GetView<AccountsController> {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Hesaplar',
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Hesap Ekle',
            onPressed: () {
              controller.goToAddAccount();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refreshAccounts,
        child: Obx(() => _buildScreenContent()),
      ),
    );
  }

  /// Ekran içeriğini durumlara göre oluşturur
  Widget _buildScreenContent() {
    // Yükleme durumu
    if (controller.isLoading.value && controller.accountList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Hesaplar yükleniyor...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    // Hata durumu
    else if (controller.errorMessage.isNotEmpty) {
      return ErrorView(
        message: controller.errorMessage.value,
        onRetry: controller.refreshAccounts,
        isLarge: true,
      ).animate().fadeIn(duration: 300.ms);
    }

    // Boş liste durumu
    else if (controller.accountList.isEmpty && !controller.isLoading.value) {
      return EmptyStateView(
        title: 'Hesap Bulunamadı',
        message:
            'Henüz bir hesap eklemediniz. Finansal durumunuzu takip etmek için hesap ekleyebilirsiniz.',
        icon: Icons.account_balance_wallet_outlined,
        onAction: controller.goToAddAccount,
        actionText: 'Hesap Ekle',
        actionIcon: Icons.add_circle_outline_rounded,
      ).animate().fadeIn(duration: 300.ms);
    }

    // Ana içerik
    else {
      return AccountsContent(controller: controller)
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(
              begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
    }
  }
}
