import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Modern bütçe özeti kartı
class BudgetSummaryCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback? onTap;

  const BudgetSummaryCard({
    super.key,
    required this.budget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Harcama oranını hesapla
    final double spentRatio =
        (budget.amount > 0) ? (budget.spentAmount / budget.amount) : 0.0;

    // Duruma göre renk belirle
    final Color statusColor = _getStatusColor(spentRatio);

    // Para birimi formatlayıcı
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    // Kategori ikonunu getir
    IconData categoryIcon = _getCategoryIcon(budget.categoryIcon);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      margin: const EdgeInsets.only(right: 16.0, bottom: 4, top: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: spentRatio > 1.0
              ? AppColors.error.withOpacity(0.3)
              : AppColors.border.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori icon ve adı
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: statusColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      budget.categoryName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // İlerleme bilgisi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${(spentRatio * 100).toInt()}%',
                      style: Get.theme.textTheme.titleMedium?.copyWith(
                        // fontSize: 16, // titleMedium zaten 16
                        fontWeight: FontWeight.bold,
                        color: statusColor, // Rengi override ediyoruz
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      currencyFormatter.format(budget.spentAmount),
                      style: Get.theme.textTheme.bodyMedium?.copyWith(
                        // fontSize: 14, // bodyMedium zaten 14
                        fontWeight: FontWeight.w500,
                        color: AppColors
                            .textPrimary, // bodyMedium textSecondary, rengi override
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // İlerleme çubuğu
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: spentRatio > 1.0 ? 1.0 : spentRatio,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),

              const SizedBox(height: 10),

              // Toplam bütçe
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Toplam:',
                    style: Get.theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12, // bodyMedium 14, 12'ye çekiyoruz
                      fontWeight: FontWeight.w500,
                      // color: AppColors.textSecondary, // bodyMedium zaten bu renkte
                    ),
                  ),
                  Text(
                    currencyFormatter.format(budget.amount),
                    style: Get.theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12, // bodyMedium 14, 12'ye çekiyoruz
                      fontWeight: FontWeight.w600,
                      color: AppColors
                          .textPrimary, // bodyMedium textSecondary, rengi override
                    ),
                  ),
                ],
              ),

              // Kalan bütçe
              if (budget.remainingAmount >= 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kalan:',
                        style: Get.theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12, // bodyMedium 14, 12'ye çekiyoruz
                          fontWeight: FontWeight.w500,
                          // color: AppColors.textSecondary, // bodyMedium zaten bu renkte
                        ),
                      ),
                      Text(
                        currencyFormatter.format(budget.remainingAmount),
                        style: Get.theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12, // bodyMedium 14, 12'ye çekiyoruz
                          fontWeight: FontWeight.w600,
                          color: spentRatio > 0.8
                              ? statusColor
                              : AppColors
                                  .textPrimary, // Rengi dinamik olarak override
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aşım:',
                        style: Get.theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12, // bodyMedium 14, 12'ye çekiyoruz
                          fontWeight: FontWeight.w500,
                          // color: AppColors.textSecondary, // bodyMedium zaten bu renkte
                        ),
                      ),
                      Text(
                        currencyFormatter.format(-budget.remainingAmount),
                        style: Get.theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12, // bodyMedium 14, 12'ye çekiyoruz
                          fontWeight: FontWeight.w600,
                          color: AppColors.error, // Rengi override ediyoruz
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kategori icon string'inden IconData oluşturur
  IconData _getCategoryIcon(String? iconString) {
    return iconString != null
        ? IconData(
            int.parse(iconString),
            fontFamily: 'MaterialIcons',
          )
        : Icons.category; // Varsayılan icon
  }

  /// Harcama oranına göre renk döndürür
  Color _getStatusColor(double ratio) {
    if (ratio > 1.0) {
      return AppColors.error;
    } else if (ratio > 0.9) {
      return AppColors.warning;
    } else if (ratio > 0.7) {
      return Colors.orange;
    } else {
      return AppColors.success;
    }
  }
}
