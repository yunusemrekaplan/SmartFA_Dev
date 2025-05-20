import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/accounts/controllers/accounts_controller.dart';
import 'package:mobile/app/modules/accounts/widgets/account_card.dart';
import 'package:mobile/app/modules/accounts/widgets/accounts_header.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Hesaplar içeriğini gösteren widget
/// SRP (Single Responsibility Principle) - Widget yalnızca hesap listesini görüntüler
class AccountsContent extends StatelessWidget {
  final AccountsController controller;

  const AccountsContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Yükleniyor göstergesi (ilk yüklemeden sonra)
            Obx(() => controller.isLoading.value
                ? Container(
                    margin: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      minHeight: 3,
                    ),
                  ).animate().fadeIn(duration: 200.ms)
                : const SizedBox(height: 8)),

            // Hesaplar başlığı
            Obx(() => AccountsHeader(
                      accountCount: controller.accountList.length,
                      totalBalance: controller.totalBalance.value,
                    ))
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Hesaplarım bölümü başlığı
            _buildSectionHeader(context)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),

            // Hesap listesi
            _buildAccountList(),

            // const SizedBox(height: 80), // Alt boşluk (FAB için)
          ],
        ),
      ),
    );
  }

  /// Bölüm başlığını oluşturur
  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0, left: 4.0, right: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Hesaplarım',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: controller.goToAddAccount,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Yeni'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Hesap listesini oluşturur
  Widget _buildAccountList() {
    return Obx(() => Column(
          children: List.generate(controller.accountList.length, (index) {
            final account = controller.accountList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: AccountCard(
                account: account,
                onTap: () => controller.goToEditAccount(account),
                onDelete: () => controller.confirmAndDeleteAccount(account),
              )
                  .animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn(duration: 400.ms)
                  .slideX(
                      begin: 0.1,
                      end: 0,
                      duration: 300.ms,
                      curve: Curves.easeOutQuad),
            );
          }),
        ));
  }
}
