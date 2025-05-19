import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/domain/models/response/budget_response_model.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'budget_action_buttons.dart';
import 'budget_amount_display.dart';
import 'budget_category_header.dart';
import 'budget_progress_bar.dart';

/// Tek bir bütçe öğesini gösteren modern kart widget'ı.
class BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final NumberFormat currencyFormatter;
  final BudgetsController controller;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.currencyFormatter,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // İlerleme çubuğu için yüzdelik değer (0.0-1.0 arasında)
    final double spentPercentage =
        budget.amount > 0 ? budget.spentAmount / budget.amount : 0;

    // İlerleme çubuğu ve vurgular için durum rengi
    Color statusColor;
    if (spentPercentage >= 1.0) {
      statusColor = AppColors.error; // Bütçeyi aşmış
    } else if (spentPercentage >= 0.85) {
      statusColor = AppColors.warning; // Bütçe limitine yaklaşıyor
    } else {
      statusColor = AppColors.success; // Normal harcama
    }

    return Card(
      elevation: 2.5,
      shadowColor: AppColors.shadowMedium,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
        side: BorderSide(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
        onTap: () => controller.goToEditBudget(budget),
        splashColor: statusColor.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.kCardBorderRadius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColors.surfaceVariant.withOpacity(0.5),
              ],
              stops: const [0.4, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori başlığı ve düğmeler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kategori başlığı bileşeni
                  Expanded(
                    child: BudgetCategoryHeader(
                      categoryName: budget.categoryName,
                      categoryIcon: budget.categoryIcon,
                      spentPercentage: spentPercentage,
                    ),
                  ),
                  // Düzenleme ve silme menüsü
                  BudgetActionButtons(
                    budget: budget,
                    controller: controller,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bütçe ilerleme çubuğu bileşeni
              BudgetProgressBar(
                spentPercentage: spentPercentage,
                statusColor: statusColor,
              ),

              const SizedBox(height: 16),

              // Bütçe miktarı ve kalan bilgileri
              BudgetAmountDisplay(
                amount: budget.amount,
                spentAmount: budget.spentAmount,
                currencyFormatter: currencyFormatter,
                statusColor: statusColor,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
