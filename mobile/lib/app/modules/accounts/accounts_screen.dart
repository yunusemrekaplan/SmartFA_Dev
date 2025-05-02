import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/modules/accounts/accounts_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/widgets/error_view.dart';
import 'package:mobile/app/modules/accounts/widgets/account_card.dart';
import 'package:mobile/app/modules/accounts/widgets/accounts_header.dart';
import 'package:mobile/app/widgets/custom_home_app_bar.dart';

/// Kullanıcının hesaplarını listeleyen modern ekran.
class AccountsScreen extends GetView<AccountsController> {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHomeAppBar(
        title: 'Hesaplar',
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: () {
              controller.refreshAccounts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hesaplar yenileniyor...'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refreshAccounts,
        child: Obx(() {
          // Yükleme durumu kontrol et
          if (controller.isLoading.value && controller.accountList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // Hata durumu
          else if (controller.errorMessage.isNotEmpty) {
            return ErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.refreshAccounts,
              isLarge: true,
            );
          }
          // Boş liste durumu
          else if (controller.accountList.isEmpty &&
              !controller.isLoading.value) {
            return _buildEmptyState(context);
          }
          // Ana içerik
          else {
            return _buildAccountsContent(context);
          }
        }),
      ),
    );
  }

  /// Hesaplar içeriğini oluşturur
  Widget _buildAccountsContent(BuildContext context) {
    final totalBalance = controller.accountList
        .fold<double>(0, (sum, account) => sum + account.currentBalance);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Yükleniyor göstergesi (ilk yüklemeden sonra)
        if (controller.isLoading.value)
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Center(child: LinearProgressIndicator()),
          ),

        // Hesaplar başlığı
        AccountsHeader(
          accountCount: controller.accountList.length,
          totalBalance: totalBalance,
        ),

        const SizedBox(height: 24),

        // Hesaplarım bölümü başlığı
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hesaplarım',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: controller.goToAddAccount,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Yeni Hesap'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        // Hesap listesi
        ...controller.accountList.map((account) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: AccountCard(
                account: account,
                onTap: () => controller.goToEditAccount(account),
                onDelete: () => _showDeleteConfirmation(context, account),
              ),
            )),

        const SizedBox(height: 80), // Alt boşluk (FAB için)
      ],
    );
  }

  /// Boş durum görünümü
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz Hesap Eklenmemiş',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Finansal durumunuzu takip etmek için hesaplarınızı eklemeye başlayın.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: controller.goToAddAccount,
            icon: const Icon(Icons.add),
            label: const Text('Hesap Ekle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Silme onay dialogunu gösterir
  void _showDeleteConfirmation(BuildContext context, AccountModel account) {
    Get.defaultDialog(
      title: "Hesabı Sil",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "'${account.name}' hesabını silmek istediğinizden emin misiniz?",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Bu işlem geri alınamaz ve hesaba bağlı tüm işlemler etkilenebilir.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
      textConfirm: "Sil",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      textCancel: "İptal",
      cancelTextColor: AppColors.textPrimary,
      onConfirm: () {
        Get.back(); // Dialogu kapat
        controller.deleteAccount(account.id);
      },
      radius: 16,
    );
  }
}
