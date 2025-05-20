import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/domain/models/response/transaction_response_model.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:mobile/app/modules/transactions/widgets/transaction_card.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// İşlem listesini ve gruplamayı yöneten Widget
class TransactionListView extends StatelessWidget {
  final TransactionsController controller;
  final NumberFormat currencyFormatter;
  final IconData Function(String?) getCategoryIcon;

  const TransactionListView({
    super.key,
    required this.controller,
    required this.currencyFormatter,
    required this.getCategoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Boş liste durumu
      if (controller.transactionList.isEmpty && !controller.isLoading.value) {
        return _buildEmptyState(context);
      }

      // Tarih gruplarına göre işlemleri ayır
      final Map<String, List<TransactionModel>> groupedTransactions = {};
      for (var transaction in controller.transactionList) {
        final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR')
            .format(transaction.transactionDate);
        if (!groupedTransactions.containsKey(dateStr)) {
          groupedTransactions[dateStr] = [];
        }
        groupedTransactions[dateStr]!.add(transaction);
      }

      // Tarih gruplarını sırala (en yeni en üstte)
      final sortedDates = groupedTransactions.keys.toList()
        ..sort((a, b) {
          final dateA = DateFormat('dd MMMM yyyy', 'tr_TR').parse(a);
          final dateB = DateFormat('dd MMMM yyyy', 'tr_TR').parse(b);
          return dateB.compareTo(dateA);
        });

      // Eğer liste boşsa veya henüz oluşturulmadıysa boş bir widget döndür
      if (sortedDates.isEmpty) {
        return const SizedBox.shrink();
      }

      return ListView.builder(
        primary: false,
        shrinkWrap: false,
        padding: EdgeInsets.zero,
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sortedDates.length + (controller.hasMoreData.value ? 1 : 0),
        itemBuilder: (context, index) {
          // Listenin sonuna geldik mi?
          if (index == sortedDates.length) {
            return controller.isLoadingMore.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const SizedBox.shrink();
          }

          // Grup başlığı ve o gruba ait işlemler
          final dateStr = sortedDates[index];
          final transactionsInGroup = groupedTransactions[dateStr] ?? [];

          // Eğer bu gruba ait hiç işlem yoksa boş widget döndür
          if (transactionsInGroup.isEmpty) {
            return const SizedBox.shrink();
          }

          // Tarih grubu başlığı ve işlemler
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tarih başlığı
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ),

                // Bu tarihe ait işlemler
                ...transactionsInGroup
                    .map((transaction) => TransactionCard(
                          transaction: transaction,
                          currencyFormatter: currencyFormatter,
                          getCategoryIcon: getCategoryIcon,
                          controller: controller,
                        ))
                    .toList(),
              ],
            ),
          );
        },
      );
    });
  }

  /// Boş durum ekranı
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sync_alt_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'İşlem Bulunamadı',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Gösterilecek işlem bulunamadı. Filtre ayarlarını değiştirebilir veya yeni işlem ekleyebilirsiniz.',
              style: Get.theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: controller.goToAddTransaction,
            icon: const Icon(Icons.add),
            label: const Text('İşlem Ekle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: Get.theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
