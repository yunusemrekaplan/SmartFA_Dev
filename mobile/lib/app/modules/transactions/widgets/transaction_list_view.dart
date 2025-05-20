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

      // Tarih gruplarını sırala
      final sortedDates = groupedTransactions.keys.toList()
        ..sort((a, b) {
          final dateA = DateFormat('dd MMMM yyyy', 'tr_TR').parse(a);
          final dateB = DateFormat('dd MMMM yyyy', 'tr_TR').parse(b);
          // Sıralama kriterine göre sıralama yönünü belirle
          if (controller.sortCriteria.value == 'date_asc') {
            return dateA.compareTo(dateB);
          } else {
            return dateB.compareTo(dateA);
          }
        });

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount:
            sortedDates.length + (controller.isLoadingMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          // Yükleme göstergesi
          if (index == sortedDates.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daha fazla işlem yükleniyor...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          final date = sortedDates[index];
          final transactions = groupedTransactions[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarih başlığı
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  date,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              // İşlem kartları
              ...transactions.map((transaction) => TransactionCard(
                    transaction: transaction,
                    currencyFormatter: currencyFormatter,
                    getCategoryIcon: getCategoryIcon,
                    controller: controller,
                  )),
            ],
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
