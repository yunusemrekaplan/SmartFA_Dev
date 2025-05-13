import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/modules/transactions/widgets/active_filters_row.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/filter_bottom_sheet.dart';
import 'package:mobile/app/modules/transactions/widgets/transaction_list_view.dart';
import 'package:mobile/app/modules/transactions/widgets/transaction_summary.dart';
import 'package:mobile/app/theme/app_colors.dart'; // Sayı ve tarih formatlama için
import 'package:mobile/app/widgets/error_view.dart'; // ErrorView widget'ını import et
import 'package:mobile/app/widgets/custom_home_app_bar.dart'; // CustomHomeAppBar widget'ını import et

/// İşlemleri listeleyen ve filtreleyen modern ekran.
class TransactionsScreen extends GetView<TransactionsController> {
  const TransactionsScreen({super.key});

  // Para formatlayıcı
  NumberFormat get currencyFormatter =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  // Kategori ikonunu döndüren yardımcı fonksiyon
  IconData _getCategoryIcon(String? iconCode) {
    return iconCode != null
        ? IconData(int.parse(iconCode), fontFamily: 'MaterialIcons')
        : Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHomeAppBar(
        title: 'İşlemler',
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrele',
            onPressed: () => _showFilterBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'İşlem Ekle',
            onPressed: () {
              controller.goToAddTransaction();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // İşlem özeti üst bölüm
          TransactionSummary(
            controller: controller,
            currencyFormatter: currencyFormatter,
          ),

          // Filtreler ve içerik
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.fetchTransactions,
              child: Obx(() {
                // Yükleme durumu
                if (controller.isLoading.value &&
                    controller.transactionList.isEmpty) {
                  return const LoadingStateView(
                    message: 'İşlemler yükleniyor...',
                  );
                }
                // Hata durumu
                else if (controller.errorMessage.isNotEmpty &&
                    controller.transactionList.isEmpty) {
                  return ErrorView(
                    message: controller.errorMessage.value,
                    onRetry: () =>
                        controller.fetchTransactions(isInitialLoad: true),
                    isLarge: true,
                  );
                }
                // Ana içerik
                else {
                  return Column(
                    children: [
                      // Aktif filtreleri gösteren alan
                      ActiveFiltersRow(controller: controller),

                      // İşlem listesi
                      Expanded(
                        child: controller.transactionList.isEmpty
                            ? EmptyStateView(
                                title: 'İşlem kaydı bulunamadı',
                                message: controller.hasActiveFilters
                                    ? 'Seçtiğiniz filtrelere uygun işlem kaydı bulunamadı. Filtrelerinizi değiştirerek tekrar deneyin.'
                                    : 'Gelir ve giderlerinizi takip etmek için işlem ekleyin.',
                                icon: Icons.sync_alt_rounded,
                                actionText: controller.hasActiveFilters
                                    ? 'Filtreleri Temizle'
                                    : 'İşlem Ekle',
                                onAction: controller.hasActiveFilters
                                    ? controller.clearFilters
                                    : controller.goToAddTransaction,
                                actionIcon: controller.hasActiveFilters
                                    ? Icons.filter_alt_off_rounded
                                    : Icons.add_circle_outline_rounded,
                              )
                            : TransactionListView(
                                controller: controller,
                                currencyFormatter: currencyFormatter,
                                getCategoryIcon: _getCategoryIcon,
                              ),
                      ),
                    ],
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Veri olmadığında gösterilecek boş durum
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: EmptyStateView(
        title: 'İşlem kaydı bulunamadı',
        message: controller.hasActiveFilters
            ? 'Seçtiğiniz filtrelere uygun işlem kaydı bulunamadı. Filtrelerinizi değiştirerek tekrar deneyin.'
            : 'Gelir ve giderlerinizi takip etmek için işlem ekleyin.',
        icon: Icons.sync_alt_rounded,
        actionText:
            controller.hasActiveFilters ? 'Filtreleri Temizle' : 'İşlem Ekle',
        onAction: controller.hasActiveFilters
            ? controller.clearFilters
            : controller.goToAddTransaction,
      ),
    );
  }

  /// Filtreleme seçeneklerini gösteren Bottom Sheet'i açar
  void _showFilterBottomSheet(BuildContext context) {
    FilterBottomSheet.show(context, controller);
  }
}
