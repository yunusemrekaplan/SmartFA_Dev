import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/modules/dashboard/widgets/transaction_summary_card.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';

/// Kategori bazlı işlem grubu widget'ı
class TransactionCategoryGroup extends StatefulWidget {
  final String categoryName;
  final double totalAmount;
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onTransactionTap;

  const TransactionCategoryGroup({
    super.key,
    required this.categoryName,
    required this.totalAmount,
    required this.transactions,
    required this.onTransactionTap,
  });

  @override
  State<TransactionCategoryGroup> createState() =>
      _TransactionCategoryGroupState();
}

class _TransactionCategoryGroupState extends State<TransactionCategoryGroup> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Para birimi formatlayıcı
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    // Kategoriden alınacak icon
    final categoryIcon =
        _getCategoryIcon(widget.transactions.first.categoryIcon);
    final categoryType = widget.transactions.first.categoryType;
    final categoryColor =
        categoryType.isIncome ? AppColors.income : AppColors.expense;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kategori başlığı ve toplam tutar (her zaman görünür)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Kategori ikonu
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: categoryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Kategori adı ve işlem sayısı
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '${widget.transactions.length} işlem',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Toplam tutar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormatter.format(widget.totalAmount),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                ),
                      ),
                      Text(
                        'Toplam',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),

                  // Genişletme/daraltma ikonu
                  IconButton(
                    icon: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // İşlem detayları (genişletildiğinde görünür)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.transactions.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      return TransactionSummaryCard(
                        transaction: widget.transactions[index],
                        onTap: () =>
                            widget.onTransactionTap(widget.transactions[index]),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Kategori icon string'inden IconData oluşturur
  IconData _getCategoryIcon(String? iconString) {
    // Boş ya da hatalı olma durumunu kontrol et
    if (iconString == null || iconString.isEmpty) {
      return Icons.category; // Varsayılan icon
    }

    try {
      return IconData(
        int.parse(iconString),
        fontFamily: 'MaterialIcons',
      );
    } catch (e) {
      // Parse hatası durumunda varsayılan
      return Icons.category;
    }
  }
}
