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
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: () {
              controller.fetchTransactions(isInitialLoad: false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('İşlemler yenileniyor...'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ana içerik
          Column(
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
                                ? _buildEmptyState(context)
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

          // Yükleme Göstergesi
          Obx(() {
            if (controller.isLoading.value &&
                controller.transactionList.isNotEmpty) {
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  color: AppColors.primary,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
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
    Get.bottomSheet(
      FilterBottomSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
