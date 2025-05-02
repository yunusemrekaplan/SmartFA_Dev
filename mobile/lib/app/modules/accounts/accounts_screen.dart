import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/account_type.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/modules/accounts/accounts_controller.dart';
import 'package:mobile/app/theme/app_colors.dart'; // Para formatlama için
import 'package:mobile/app/widgets/error_view.dart'; // ErrorView widget'ını import et

/// Kullanıcının hesaplarını listeleyen ekran.
class AccountsScreen extends GetView<AccountsController> {
  const AccountsScreen({super.key});

  // Para formatlayıcı
  NumberFormat get currencyFormatter =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  // Hesap türüne göre ikon döndüren yardımcı fonksiyon
  IconData _getAccountIcon(AccountType accountType) {
    // AccountModel'deki type string'ine göre ikon döndür
    // Bu eşleştirme backend DTO'sundaki enum string'ine göre yapılmalı
    switch (accountType) {
      case AccountType.Cash:
        return Icons.wallet_outlined;
      case AccountType.Bank: // Backend'den gelen değere göre düzelt
        return Icons.account_balance_outlined;
      case AccountType.CreditCard: // Backend'den gelen değere göre düzelt
        return Icons.credit_card_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refreshAccounts,
        child: Obx(() {
          // State değişikliklerini dinle
          // 1. Yüklenme Durumu
          if (controller.isLoading.value && controller.accountList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Hata Durumu
          else if (controller.errorMessage.isNotEmpty) {
            // Yeni ErrorView widget'ını kullan
            return ErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.refreshAccounts,
              isLarge: true,
            );
          }
          // 3. Boş Liste Durumu
          else if (controller.accountList.isEmpty &&
              !controller.isLoading.value) {
            // Veri bulunamadı durumu için ErrorView widget'ını kullan
            return ErrorView.noData(
              message: 'Henüz hesap eklenmemiş.',
              onRetry: controller.refreshAccounts,
              onAdd: controller.goToAddAccount,
            );
          }
          // 4. Hesap Listesi
          else {
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.accountList.length,
              itemBuilder: (context, index) {
                final account = controller.accountList[index];
                return _buildAccountTile(context, account);
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10), // Kartlar arası boşluk
            );
          }
        }),
      ),
    );
  }

  /// Tek bir hesap öğesini gösteren kart widget'ını oluşturur.
  Widget _buildAccountTile(BuildContext context, AccountModel account) {
    final Color balanceColor =
        account.currentBalance >= 0 ? AppColors.textPrimary : AppColors.error;
    final IconData accountIcon = _getAccountIcon(account.type);

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          child:
              Icon(accountIcon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          account.name,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          accountTypeToString(account.type),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          currencyFormatter.format(account.currentBalance),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: balanceColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        onTap: () {
          // TODO: Hesap detayına gitme veya düzenleme seçeneği
          controller.goToEditAccount(account); // Düzenlemeye yönlendir
          print('Hesap tıklandı: ${account.name}');
        },
        // Opsiyonel: Silme ve Düzenleme için PopupMenuButton veya Slidable kullanılabilir
        // trailing: PopupMenuButton<String>(
        //    onSelected: (String result) {
        //       if (result == 'edit') {
        //          controller.goToEditAccount(account);
        //       } else if (result == 'delete') {
        //          // Onay dialogu göster
        //          Get.defaultDialog(
        //             title: "Hesabı Sil",
        //             middleText: "'${account.name}' hesabını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.",
        //             textConfirm: "Sil",
        //             textCancel: "İptal",
        //             confirmTextColor: Colors.white,
        //             onConfirm: () {
        //                Get.back(); // Dialogu kapat
        //                controller.deleteAccount(account.id);
        //             }
        //          );
        //       }
        //    },
        //    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        //       const PopupMenuItem<String>(
        //          value: 'edit',
        //          child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Düzenle')),
        //       ),
        //       const PopupMenuItem<String>(
        //          value: 'delete',
        //          child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Sil', style: TextStyle(color: Colors.red))),
        //       ),
        //    ],
        //    icon: Icon(Icons.more_vert),
        //  ),
      ),
    );
  }
}
