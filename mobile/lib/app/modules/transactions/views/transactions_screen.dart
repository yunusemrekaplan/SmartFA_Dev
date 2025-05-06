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
  NumberFormat get currencyFormatter => NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

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
                if (controller.isLoading.value && controller.transactionList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Hata durumu
                else if (controller.errorMessage.isNotEmpty && controller.transactionList.isEmpty) {
                  return ErrorView(
                    message: controller.errorMessage.value,
                    onRetry: () => controller.fetchTransactions(isInitialLoad: true),
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
                        child: TransactionListView(
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

  /// Filtreleme seçeneklerini gösteren Bottom Sheet'i açar
  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      FilterBottomSheet(controller: controller), // Yeni widget'ı çağır
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
