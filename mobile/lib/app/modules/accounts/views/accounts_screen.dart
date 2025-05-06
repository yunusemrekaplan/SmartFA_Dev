import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/modules/accounts/controllers/accounts_controller.dart';
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
            return _EmptyAccountsState(controller: controller); // Yeni widget
          }
          // Ana içerik
          else {
            return _AccountsContent(controller: controller); // Yeni widget
          }
        }),
      ),
    );
  }

  // _buildAccountsContent metodu _AccountsContent widget'ına taşındı.
  // _buildEmptyState metodu _EmptyAccountsState widget'ına taşındı.

  /// Silme onay dialogunu gösterir
  void _showDeleteConfirmation(BuildContext context, AccountModel account) {
    Get.defaultDialog(
      title: "Hesabı Sil",
      titleStyle: Get.theme.dialogTheme.titleTextStyle?.copyWith(
        fontWeight: FontWeight.bold, // Dialog teması w600, bold yapıyoruz
      ),
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
            style: Get.theme.dialogTheme
                .contentTextStyle, // Dialog content (16) tam uyuyor
          ),
          const SizedBox(height: 8),
          Text(
            "Bu işlem geri alınamaz ve hesaba bağlı tüm işlemler etkilenebilir.",
            textAlign: TextAlign.center,
            style: Get.theme.dialogTheme.contentTextStyle?.copyWith(
              fontSize: 14, // Dialog content (16), 14'e çekiyoruz
              color: AppColors.textSecondary,
            ),
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

// --- Ayrılmış Widget Sınıfları ---

/// Hesaplar içeriğini gösteren widget
class _AccountsContent extends StatelessWidget {
  final AccountsController controller;

  const _AccountsContent({required this.controller});

  // _showDeleteConfirmation metodunu buraya taşıdık, çünkü AccountCard buradan çağrılıyor.
  void _showDeleteConfirmation(BuildContext context, AccountModel account) {
    Get.defaultDialog(
      title: "Hesabı Sil",
      titleStyle: Get.theme.dialogTheme.titleTextStyle?.copyWith(
        fontWeight: FontWeight.bold,
      ),
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
            style: Get.theme.dialogTheme.contentTextStyle,
          ),
          const SizedBox(height: 8),
          Text(
            "Bu işlem geri alınamaz ve hesaba bağlı tüm işlemler etkilenebilir.",
            textAlign: TextAlign.center,
            style: Get.theme.dialogTheme.contentTextStyle?.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
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

  @override
  Widget build(BuildContext context) {
    final totalBalance = controller.accountList
        .fold<double>(0, (sum, account) => sum + account.currentBalance);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Yükleniyor göstergesi (ilk yüklemeden sonra)
        Obx(() => controller.isLoading.value
            ? const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Center(child: LinearProgressIndicator()),
              )
            : const SizedBox.shrink()),

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
                  textStyle: Theme.of(context)
                      .textButtonTheme
                      .style
                      ?.textStyle
                      ?.resolve({})?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Hesap listesi
        Obx(() => Column(
              // Obx ile sarmaladık ki liste güncellensin
              children: controller.accountList
                  .map((account) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AccountCard(
                          account: account,
                          onTap: () => controller.goToEditAccount(account),
                          onDelete: () => _showDeleteConfirmation(
                              context, account), // Buradan çağırıyoruz
                        ),
                      ))
                  .toList(),
            )),

        const SizedBox(height: 80), // Alt boşluk (FAB için)
      ],
    );
  }
}

/// Hesap olmadığında gösterilen boş durum widget'ı
class _EmptyAccountsState extends StatelessWidget {
  final AccountsController controller;

  const _EmptyAccountsState({required this.controller});

  @override
  Widget build(BuildContext context) {
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
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
              textStyle: Theme.of(context)
                  .elevatedButtonTheme
                  .style
                  ?.textStyle
                  ?.resolve({})?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
