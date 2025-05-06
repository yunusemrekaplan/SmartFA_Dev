import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/dashboard/dashboard_controller.dart';
import 'package:mobile/app/modules/dashboard/widgets/budget_summary_card.dart';
import 'package:mobile/app/modules/dashboard/widgets/income_expense_chart.dart';
import 'package:mobile/app/widgets/info_panel.dart'; // Güncellenmiş yol
import 'package:mobile/app/widgets/section_header.dart'; // Güncellenmiş yol
import 'package:mobile/app/modules/dashboard/widgets/transaction_summary_card.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/widgets/error_view.dart';
import 'package:mobile/app/widgets/custom_home_app_bar.dart';

/// Modern dashboard ekranı, finans özetini görsel öğelerle gösterir
class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  // Sayı formatlayıcı (para birimi için)
  // Intl paketinin locale ayarlarının main.dart veya başlangıçta yapıldığını varsayıyoruz.
  NumberFormat get currencyFormatter => NumberFormat.currency(
      locale: 'tr_TR', symbol: '₺'); // Türkçe locale ve TL simgesi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHomeAppBar(
        title: 'Özet',
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Bildirimler',
            onPressed: () {
              // TODO: Bildirimler sayfasına yönlendir
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bildirimler henüz yapım aşamasında'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: () {
              controller.refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Veriler yenileniyor...'),
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
        onRefresh: controller.refreshData,
        child: Obx(() {
          // Yükleme durumu kontrol et
          if (controller.isLoading.value &&
              controller.recentTransactions.isEmpty &&
              controller.budgetSummaries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Hata durumunu kontrol et (Tamamen yüklenemediği durumda)
          if (controller.errorMessage.isNotEmpty &&
              controller.recentTransactions.isEmpty &&
              controller.budgetSummaries.isEmpty) {
            return ErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.refreshData,
              isLarge: true,
            );
          }

          // Ana içerik
          return _buildDashboardContent(context);
        }),
      ),
    );
  }

  /// Dashboard içeriğini oluşturur
  Widget _buildDashboardContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Yükleniyor göstergesi (ilk yüklemeden sonra)
        if (controller.isLoading.value)
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Center(child: LinearProgressIndicator()),
          ),

        // Hata mesajı (kısmi hata durumu için)
        if (controller.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InfoPanel.error(
              title: 'Veri Yükleme Hatası',
              message: controller.errorMessage.value,
              onActionPressed: controller.refreshData,
              actionText: 'Yenile',
            ),
          ),

        // --- Bakiye Kartı ---
        /*Obx(() => BalanceCard(
              totalBalance: controller.totalBalance.value,
              onRefresh: controller.refreshData,
              onViewDetails: controller.navigateToAccounts,
            )),

        const SizedBox(height: 24),*/

        // --- Gelir-Gider Özeti Grafik ---
        Obx(() => IncomeExpenseChart(
              income: controller.totalIncome.value,
              expense: controller.totalExpense.value,
              period: 'Bu Ay',
              onViewDetails: controller.navigateToAnalysis,
            )),

        const SizedBox(height: 24),

        // --- Bütçe Özetleri Bölümü ---
        _buildBudgetSection(context),

        const SizedBox(height: 8),

        // Aşılan bütçe uyarısı (varsa)
        Obx(() {
          if (controller.hasOverspentBudgets.value) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: InfoPanel.warning(
                title: 'Bütçe Aşımı',
                message:
                    'Bazı bütçelerinizde aşım tespit edildi. Lütfen harcamalarınızı kontrol edin.',
                onActionPressed: controller.navigateToBudgets,
                actionText: 'Bütçeleri Görüntüle',
              ),
            );
          } else {
            return const SizedBox(height: 24);
          }
        }),

        // --- Son İşlemler Bölümü ---
        _buildRecentTransactionsSection(context),

        const SizedBox(height: 16),

        // --- Hesap Bilgisi ---
        Obx(() => InfoPanel.info(
              title: 'Hesap Bilgisi',
              message:
                  '${controller.accountCount} aktif hesabınız bulunmaktadır.',
              onActionPressed: controller.navigateToAccounts,
              actionText: 'Hesapları Yönet',
            )),

        const SizedBox(height: 50), // Alt boşluk
      ],
    );
  }

  // --- Dashboard İçerik Oluşturma Metotları ---

  /// Bütçe özet bölümünü oluşturur (Widget'a taşındı)
  Widget _buildBudgetSection(BuildContext context) {
    return _BudgetSectionWidget(controller: controller);
  }

  /// Son işlemler bölümünü oluşturur (Widget'a taşındı)
  Widget _buildRecentTransactionsSection(BuildContext context) {
    return _RecentTransactionsSectionWidget(controller: controller);
  }
}

// --- Ayrılmış Widget Sınıfları ---

/// Bütçe Özetleri Bölümü Widget'ı
class _BudgetSectionWidget extends StatelessWidget {
  final DashboardController controller;

  const _BudgetSectionWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bölüm başlığı
        SectionHeader(
          title: 'Bu Ayın Bütçeleri',
          subtitle: 'Harcamalarınızı izleyin ve yönetin',
          onActionPressed: controller.navigateToBudgets,
          actionText: 'Tümünü Gör',
          actionIcon: Icons.arrow_forward_rounded,
        ),

        // Bütçe listesi
        Obx(() {
          if (controller.budgetSummaries.isEmpty &&
              !controller.isLoading.value) {
            return SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz bütçe tanımlanmamış',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/budgets/add');
                      },
                      child: const Text('Bütçe Oluştur'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.budgetSummaries.isEmpty &&
              controller.isLoading.value) {
            return const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.budgetSummaries.length,
              itemBuilder: (context, index) {
                final budget = controller.budgetSummaries[index];
                return BudgetSummaryCard(
                  budget: budget,
                  onTap: () {
                    // Bütçe detay sayfasına gidebilir
                    //Get.toNamed('/budgets/${budget.id}');
                  },
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

/// Son İşlemler Bölümü Widget'ı
class _RecentTransactionsSectionWidget extends StatelessWidget {
  final DashboardController controller;

  const _RecentTransactionsSectionWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bölüm başlığı
        SectionHeader(
          title: 'Son İşlemler',
          subtitle: 'En son gerçekleşen finansal hareketleriniz',
          onActionPressed: controller.navigateToTransactions,
          actionText: 'Tümünü Gör',
          actionIcon: Icons.arrow_forward_rounded,
        ),

        // İşlem listesi
        Obx(() {
          if (controller.recentTransactions.isEmpty &&
              !controller.isLoading.value) {
            return SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sync_alt_rounded,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz işlem kaydedilmemiş',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/transactions/add');
                      },
                      child: const Text('İşlem Ekle'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.recentTransactions.isEmpty &&
              controller.isLoading.value) {
            return const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = controller.recentTransactions[index];
              return TransactionSummaryCard(
                transaction: transaction,
                onTap: () {
                  // İşlem detay sayfasına gidebilir
                  //Get.toNamed('/transactions/${transaction.id}');
                },
              );
            },
          );
        }),
      ],
    );
  }
}
