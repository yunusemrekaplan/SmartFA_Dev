import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/accounts/controllers/accounts_controller.dart';
import 'package:mobile/app/modules/accounts/widgets/accounts_content.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/widgets/empty_state_view.dart';
import 'package:mobile/app/widgets/content_view.dart';
import 'package:mobile/app/widgets/custom_app_bar.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';

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
      body: ContentView<AccountModel>(
        contentView: AccountsContent(controller: controller),
        isLoading: controller.isLoading,
        errorMessage: controller.errorMessage,
        items: controller.accountList,
        onRetry: () => controller.loadAccounts(),
        loadingMessage: 'Hesaplar yükleniyor...',
        showLoadingOverlay: true,
        progressColor: AppColors.primary,
        emptyStateView: EmptyStateView(
          title: 'Hesap Bulunamadı',
          message:
              'Henüz bir hesap eklemediniz. Finansal durumunuzu takip etmek için hesap ekleyebilirsiniz.',
          icon: Icons.account_balance_wallet_outlined,
          onAction: controller.goToAddAccount,
          actionText: 'Hesap Ekle',
          actionIcon: Icons.add_circle_outline_rounded,
        ),
      ),
    );
  }
}
