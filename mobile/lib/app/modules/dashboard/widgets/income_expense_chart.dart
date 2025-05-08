import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Gelir-gider dağılımını gösteren grafik kartı
class IncomeExpenseChart extends StatefulWidget {
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
  State<IncomeExpenseChart> createState() => _IncomeExpenseChartState();
}

class _IncomeExpenseChartState extends State<IncomeExpenseChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Para birimi formatlayıcı
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    final double balance = widget.income - widget.expense;
    final bool isBalancePositive = balance >= 0;

    // Yüzde hesaplamaları
    double incomePercent = 0;
    double expensePercent = 0;

    if (widget.income > 0 || widget.expense > 0) {
      final double total = widget.income + widget.expense;
      incomePercent = (widget.income / total) * 100;
      expensePercent = (widget.expense / total) * 100;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            isBalancePositive
                ? AppColors.success.withOpacity(0.05)
                : AppColors.error.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.period} Özeti',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (widget.onViewDetails != null)
                  TextButton.icon(
                    onPressed: widget.onViewDetails,
                    icon: const Icon(Icons.bar_chart_rounded, size: 18),
                    label: const Text("Detaylar"),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Denge (Gelir-Gider farkı)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isBalancePositive
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isBalancePositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: isBalancePositive
                          ? AppColors.success
                          : AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genel Durum',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              currencyFormatter.format(balance.abs()),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isBalancePositive
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                isBalancePositive ? 'Kazanç' : 'Kayıp',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isBalancePositive
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate(
              controller: _animationController,
              effects: [
                FadeEffect(duration: 500.ms, curve: Curves.easeOut),
                SlideEffect(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                    duration: 500.ms),
              ],
            ),

            const SizedBox(height: 24),

            // Grafik başlık
            Text(
              'Gelir-Gider Dağılımı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 12),

            // Grafik alanı
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Gelir çubuğu
                      Expanded(
                        flex: (incomePercent * _animation.value).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(8),
                              bottomLeft: const Radius.circular(8),
                              topRight:
                                  Radius.circular(expensePercent < 0.1 ? 8 : 0),
                              bottomRight:
                                  Radius.circular(expensePercent < 0.1 ? 8 : 0),
                            ),
                            gradient: LinearGradient(
                              colors: AppColors.successGradient,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      // Gider çubuğu
                      Expanded(
                        flex: (expensePercent * _animation.value).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: const Radius.circular(8),
                              bottomRight: const Radius.circular(8),
                              topLeft:
                                  Radius.circular(incomePercent < 0.1 ? 8 : 0),
                              bottomLeft:
                                  Radius.circular(incomePercent < 0.1 ? 8 : 0),
                            ),
                            gradient: LinearGradient(
                              colors: AppColors.dangerGradient,
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Gelir ve gider bilgileri
            Row(
              children: [
                // Gelir kutusu
                Expanded(
                  child: _FinancialInfoCard(
                    title: 'Gelir',
                    amount: widget.income,
                    percentage: incomePercent,
                    isIncome: true,
                    animation: _animation,
                  ),
                ),

                const SizedBox(width: 12),

                // Gider kutusu
                Expanded(
                  child: _FinancialInfoCard(
                    title: 'Gider',
                    amount: widget.expense,
                    percentage: expensePercent,
                    isIncome: false,
                    animation: _animation,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialInfoCard extends StatelessWidget {
  final String title;
  final double amount;
  final double percentage;
  final bool isIncome;
  final Animation<double> animation;

  const _FinancialInfoCard({
    required this.title,
    required this.amount,
    required this.percentage,
    required this.isIncome,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isIncome
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      color: isIncome
          ? AppColors.success.withOpacity(0.05)
          : AppColors.error.withOpacity(0.05),
      child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isIncome ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isIncome
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isIncome
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(amount * animation.value),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '%${(percentage * animation.value).round()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
