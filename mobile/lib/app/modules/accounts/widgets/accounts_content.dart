import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/accounts/controllers/accounts_controller.dart';
import 'package:mobile/app/modules/accounts/widgets/account_card.dart';
import 'package:mobile/app/modules/accounts/widgets/accounts_header.dart';

/// Hesaplar içeriğini gösteren widget
/// SRP (Single Responsibility Principle) - Widget yalnızca hesap listesini görüntüler
class AccountsContent extends StatelessWidget {
  final AccountsController controller;

  const AccountsContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
          totalBalance: controller.totalBalance,
        ),

        const SizedBox(height: 24),

        // Hesaplarım bölümü başlığı
        _buildSectionHeader(context),

        // Hesap listesi
        _buildAccountList(),

        const SizedBox(height: 80), // Alt boşluk (FAB için)
      ],
    );
  }

  /// Bölüm başlığını oluşturur
  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }

  /// Hesap listesini oluşturur
  Widget _buildAccountList() {
    return Obx(() => Column(
          children: controller.accountList
              .map((account) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AccountCard(
                      account: account,
                      onTap: () => controller.goToEditAccount(account),
                      onDelete: () =>
                          controller.confirmAndDeleteAccount(account),
                    ),
                  ))
              .toList(),
        ));
  }
}
