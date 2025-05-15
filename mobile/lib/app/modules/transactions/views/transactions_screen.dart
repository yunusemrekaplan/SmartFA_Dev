import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/modules/transactions/widgets/active_filters_row.dart';
import 'package:mobile/app/modules/transactions/widgets/filter_bottom_sheet/filter_bottom_sheet.dart';
import 'package:mobile/app/modules/transactions/widgets/transaction_list_view.dart';
import 'package:mobile/app/modules/transactions/widgets/transaction_summary.dart';
import 'package:mobile/app/theme/app_colors.dart'; // Sayı ve tarih formatlama için
import 'package:mobile/app/theme/app_theme.dart';
import 'package:mobile/app/widgets/empty_state_view.dart';
import 'package:mobile/app/widgets/custom_app_bar.dart';
import 'package:mobile/app/widgets/refreshable_content_view.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';

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
      appBar: CustomAppBar(
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

          // Ana içerik - RefreshableContentView ile sarmalanmış
          Expanded(
            child: Obx(() {
              // Aktif filtreler varsa göster
              Widget? filtersWidget;
              if (controller.hasActiveFilters) {
                filtersWidget = ActiveFiltersRow(controller: controller);
              }

              return RefreshableContentView<TransactionModel>(
                isLoading: controller.isLoading,
                errorMessage: controller.errorMessage,
                onRefresh: () =>
                    controller.fetchTransactions(isInitialLoad: false),
                contentPadding: EdgeInsets.zero, // Padding'i kaldırdık
                showLoadingOverlay: true,
                progressColor: AppColors.primary,
                loadingMessage: 'İşlemler yükleniyor...',
                items: controller.transactionList,
                headerWidget:
                    filtersWidget, // Filtreleri header olarak ekliyoruz
                emptyStateView: EmptyStateView(
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
                ),
                contentView: Padding(
                  padding: const EdgeInsets.all(AppTheme.kHorizontalPadding),
                  child: TransactionListView(
                    controller: controller,
                    currencyFormatter: currencyFormatter,
                    getCategoryIcon: _getCategoryIcon,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Filtreleme seçeneklerini gösteren Bottom Sheet'i açar
  void _showFilterBottomSheet(BuildContext context) {
    FilterBottomSheet.show(context, controller);
  }
}
