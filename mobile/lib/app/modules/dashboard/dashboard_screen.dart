import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/dashboard/dashboard_controller.dart';
import 'package:mobile/app/modules/dashboard/widgets/budget_summary_card.dart';
import 'package:mobile/app/modules/dashboard/widgets/income_expense_chart.dart';
import 'package:mobile/app/widgets/empty_state_view.dart';
import 'package:mobile/app/widgets/info_panel.dart';
import 'package:mobile/app/modules/dashboard/widgets/section_header.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:mobile/app/widgets/custom_app_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/modules/dashboard/widgets/grouped_transactions/grouped_transaction_list.dart';
import 'package:mobile/app/widgets/refreshable_content_view.dart';

/// Modern dashboard ekranı, finans özetini görsel öğelerle gösterir
class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  // Sayı formatlayıcı (para birimi için)
  NumberFormat get currencyFormatter =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
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
              controller.refreshDashboardData();
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
      body: Obx(() => RefreshableContentView<dynamic>(
            isLoading: controller.isLoading,
            errorMessage: controller.errorMessage,
            onRefresh: controller.refreshDashboardData,
            contentPadding: const EdgeInsets.all(AppTheme.kHorizontalPadding),
            showLoadingOverlay: true,
            progressColor: AppColors.primary,
            loadingMessage: 'Finans verileri yükleniyor...',
            items: _hasContent()
                ? null // İçerik var, kontrol etmeye gerek yok
                : RxList<int>.empty(), // İçerik yok, boş liste gönder
            contentView: _buildDashboardContent(context),
          )),
    );
  }

  /// Dashboard içeriğini oluşturur
  Widget _buildDashboardContent(BuildContext context) {
    return ListView(
      physics:
          const NeverScrollableScrollPhysics(), // Ana scrolling RefreshableContentView tarafından yönetiliyor
      shrinkWrap: true,
      children: [
        // Yükleniyor veya hata durumları RefreshableContentView tarafından ele alınıyor

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

        // Aşılan bütçe uyarısı (varsa)
        Obx(() {
          if (controller.hasOverspentBudgets.value) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
              child: InfoPanel.warning(
                title: 'Bütçe Aşımı',
                message:
                    'Bazı bütçelerinizde aşım tespit edildi. Lütfen harcamalarınızı kontrol edin.',
                onActionPressed: controller.navigateToBudgets,
                actionText: 'Bütçeleri Görüntüle',
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
          } else {
            return const SizedBox(height: 16);
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
            )).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
      ],
    );
  }

  // --- Dashboard İçerik Oluşturma Metotları ---

  /// Bütçe özet bölümünü oluşturur
  Widget _buildBudgetSection(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: 100.ms),
        SlideEffect(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
          duration: 400.ms,
          delay: 100.ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Column(
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
              return EmptyStateView(
                title: 'Henüz bütçe yok',
                message:
                    'Harcamalarınızı planlayarak bütçelemenizi yapın ve finansal hedeflerinize ulaşın.',
                icon: Icons.account_balance_wallet_outlined,
                actionText: 'Bütçe Oluştur',
                onAction: () => Get.toNamed('/budgets/add'),
              );
            }

            if (controller.budgetSummaries.isEmpty &&
                controller.isLoading.value) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.budgetSummaries.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final budget = controller.budgetSummaries[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == controller.budgetSummaries.length - 1
                          ? 0
                          : 12,
                    ),
                    child: BudgetSummaryCard(
                      budget: budget,
                      onTap: () {
                        // Bütçe detay sayfasına git
                      },
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Son işlemler bölümünü oluşturur
  Widget _buildRecentTransactionsSection(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: 200.ms),
        SlideEffect(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
          duration: 400.ms,
          delay: 200.ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Column(
        children: [
          // Bölüm başlığı
          SectionHeader(
            title: 'Son İşlemler',
            subtitle: 'Kategorilere göre düzenlenmiş finansal hareketleriniz',
            onActionPressed: controller.navigateToTransactions,
            actionText: 'Tümünü Gör',
            actionIcon: Icons.arrow_forward_rounded,
          ),

          // İşlem listesi
          Obx(() {
            if (controller.recentTransactions.isEmpty &&
                !controller.isLoading.value) {
              return EmptyStateView(
                title: 'İşlem kaydı yok',
                message:
                    'Gelir ve giderlerinizi takip etmek için işlem ekleyin ve finansal durumunuzu daha iyi anlayın.',
                icon: Icons.sync_alt_rounded,
                actionText: 'İşlem Ekle',
                onAction: () => Get.toNamed('/transactions/add'),
              );
            }

            if (controller.recentTransactions.isEmpty &&
                controller.isLoading.value) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Kategorilere göre gruplandırılmış işlem listesi
            return GroupedTransactionList(
              transactions: controller.recentTransactions,
              onTransactionTap: (transaction) {
                // İşlem detay sayfasına git
              },
            );
          }),
        ],
      ),
    );
  }

  bool _hasContent() {
    return controller.recentTransactions.isNotEmpty ||
        controller.budgetSummaries.isNotEmpty;
  }
}
