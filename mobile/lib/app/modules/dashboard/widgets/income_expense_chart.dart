import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Gelir-gider dağılımını gösteren grafik kartı
class IncomeExpenseChart extends StatelessWidget {
  final double income;
  final double expense;
  final String period; // "Bu Ay", "Bu Hafta" vb.
  final VoidCallback? onViewDetails;

  const IncomeExpenseChart({
    super.key,
    required this.income,
    required this.expense,
    this.period = 'Bu Ay',
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Para birimi formatlayıcı
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    final double balance = income - expense;
    final bool isBalancePositive = balance >= 0;

    // Yüzde hesaplamaları
    double incomePercent = 0;
    double expensePercent = 0;

    if (income > 0 || expense > 0) {
      final double total = income + expense;
      incomePercent = (income / total) * 100;
      expensePercent = (expense / total) * 100;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: AppColors.border.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kart başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$period Özeti',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (onViewDetails != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, size: 20),
                    onPressed: onViewDetails,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Detayları Gör',
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Denge (Gelir-Gider farkı)
            Row(
              children: [
                Text(
                  'Denge:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  currencyFormatter.format(balance),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isBalancePositive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isBalancePositive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isBalancePositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 16,
                        color: isBalancePositive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBalancePositive ? 'Kazanç' : 'Kayıp',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13, // bodyMedium 14, 13'e çekiyoruz
                              fontWeight: FontWeight.w600,
                              color: isBalancePositive
                                  ? AppColors.success
                                  : AppColors.error, // Rengi override
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Grafik alanı
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.border,
              ),
              child: Row(
                children: [
                  // Gelir çubuğu
                  Expanded(
                    flex: incomePercent.round(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(6),
                          bottomLeft: const Radius.circular(6),
                          topRight:
                              Radius.circular(expensePercent < 0.1 ? 6 : 0),
                          bottomRight:
                              Radius.circular(expensePercent < 0.1 ? 6 : 0),
                        ),
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  // Gider çubuğu
                  Expanded(
                    flex: expensePercent.round(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: const Radius.circular(6),
                          bottomRight: const Radius.circular(6),
                          topLeft: Radius.circular(incomePercent < 0.1 ? 6 : 0),
                          bottomLeft:
                              Radius.circular(incomePercent < 0.1 ? 6 : 0),
                        ),
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Gelir ve gider bilgileri
            Row(
              children: [
                // Gelir kutusu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gelir',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight
                                      .w500, // bodyMedium w400, w500 yapıyoruz
                                  // color: AppColors.textSecondary, // Zaten bodyMedium rengi
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormatter.format(income),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '%${incomePercent.round()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12, // bodyMedium 14, 12'ye çekiyoruz
                              // color: AppColors.textSecondary, // Zaten bodyMedium rengi
                            ),
                      ),
                    ],
                  ),
                ),

                // Gider kutusu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gider',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight
                                      .w500, // bodyMedium w400, w500 yapıyoruz
                                  // color: AppColors.textSecondary, // Zaten bodyMedium rengi
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormatter.format(expense),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '%${expensePercent.round()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12, // bodyMedium 14, 12'ye çekiyoruz
                              // color: AppColors.textSecondary, // Zaten bodyMedium rengi
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Detay butonu (opsiyonel)
            if (onViewDetails != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: TextButton(
                    onPressed: onViewDetails,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Detaylı Analizi Gör',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors
                                        .primary, // bodyMedium textSecondary, rengi override
                                  ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
