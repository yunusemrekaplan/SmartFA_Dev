import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/domain/models/response/transaction_response_model.dart';
import 'package:mobile/app/modules/dashboard/widgets/grouped_transactions/transaction_category_group.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Kategori bazlı gruplandırılmış işlem listesi widget'ı
class GroupedTransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onTransactionTap;

  const GroupedTransactionList({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    // Eğer işlem yoksa, boş durum widget'ı göster
    if (transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    // İşlemleri kategorilere göre grupla
    final groupedTransactions = _groupTransactionsByCategory();

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...groupedTransactions.entries.map((entry) {
          final categoryName = entry.key;
          final categoryTransactions = entry.value;
          final totalAmount = _calculateTotalAmount(categoryTransactions);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TransactionCategoryGroup(
              categoryName: categoryName,
              totalAmount: totalAmount,
              transactions: categoryTransactions,
              onTransactionTap: onTransactionTap,
            ),
          );
        }),
      ],
    );
  }

  /// İşlemleri kategoriye göre gruplar
  Map<String, List<TransactionModel>> _groupTransactionsByCategory() {
    final Map<String, List<TransactionModel>> grouped = {};

    for (final transaction in transactions) {
      final categoryName = transaction.categoryName;

      if (!grouped.containsKey(categoryName)) {
        grouped[categoryName] = [];
      }

      grouped[categoryName]!.add(transaction);
    }

    // Kategorileri toplam tutara göre sırala (büyükten küçüğe)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aTotalAmount = _calculateTotalAmount(grouped[a]!);
        final bTotalAmount = _calculateTotalAmount(grouped[b]!);
        return bTotalAmount.compareTo(aTotalAmount);
      });

    // Sıralanmış yeni bir map oluştur
    final sortedMap = <String, List<TransactionModel>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  /// Verilen işlem listesindeki toplam tutarı hesaplar
  double _calculateTotalAmount(List<TransactionModel> transactions) {
    return transactions.fold(
        0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Boş durum widget'ı oluşturur
  Widget _buildEmptyState(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(
              Icons.sync_alt_rounded,
              size: 64,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'İşlem kaydı yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gelir ve giderlerinizi takip etmek için işlem ekleyin',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
