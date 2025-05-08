import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    IconData statusIcon;
    String statusText;

    if (spentPercentage >= 1.0) {
      statusColor = AppColors.error; // Bütçeyi aşmış
      statusIcon = Icons.error_outline_rounded;
      statusText = 'Bütçe Aşımı';
    } else if (spentPercentage >= 0.85) {
      statusColor = AppColors.warning; // Bütçe limitine yaklaşıyor
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'Limit Yakın';
    } else {
      statusColor = AppColors.success; // Normal harcama
      statusIcon = Icons.check_circle_outline_rounded;
      statusText = 'Normal';
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
              // Kategori adı ve ikon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withOpacity(0.2),
                              width: 1.0,
                            ),
                          ),
                          child: budget.categoryIcon != null &&
                                  budget.categoryIcon!.isNotEmpty
                              ? Icon(
                                  IconData(int.parse(budget.categoryIcon!),
                                      fontFamily: 'MaterialIcons'),
                                  color: statusColor,
                                  size: 24,
                                )
                              : Icon(
                                  Icons.category_outlined,
                                  color: statusColor,
                                  size: 24,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                budget.categoryName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusIcon,
                                      size: 12,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'edit') {
                        controller.goToEditBudget(budget);
                      } else if (result == 'delete') {
                        // Onay dialogu göster
                        Get.defaultDialog(
                          title: "Bütçeyi Sil",
                          middleText:
                              "'${budget.categoryName}' kategorisi için bütçeyi silmek istediğinizden emin misiniz?",
                          textConfirm: "Sil",
                          textCancel: "İptal",
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            Get.back(); // Dialogu kapat
                            controller.deleteBudget(budget.id);
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Düzenle'),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          title: Text(
                            'Sil',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.red,
                                ),
                          ),
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bütçe ilerleme çubuğu
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.0,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      height: 14,
                      width: MediaQuery.of(context).size.width *
                          0.9 *
                          spentPercentage.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(8),
                          bottomLeft: const Radius.circular(8),
                          topRight: spentPercentage >= 1.0
                              ? const Radius.circular(8)
                              : Radius.zero,
                          bottomRight: spentPercentage >= 1.0
                              ? const Radius.circular(8)
                              : Radius.zero,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            statusColor.withOpacity(0.7),
                            statusColor,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bütçe tutar bilgileri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Harcanan miktar
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Harcanan',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currencyFormatter.format(budget.spentAmount),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: spentPercentage >= 1.0
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Toplam/Kalan miktar
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: budget.remainingAmount < 0
                            ? AppColors.error.withOpacity(0.08)
                            : AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: budget.remainingAmount < 0
                              ? AppColors.error.withOpacity(0.2)
                              : AppColors.success.withOpacity(0.2),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                budget.remainingAmount < 0
                                    ? Icons.trending_down
                                    : Icons.trending_up,
                                size: 16,
                                color: budget.remainingAmount < 0
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Kalan',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currencyFormatter.format(budget.remainingAmount),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: budget.remainingAmount < 0
                                      ? AppColors.error
                                      : AppColors.success,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Toplam bütçe
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Toplam Bütçe: ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: currencyFormatter.format(budget.amount),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 50.ms).scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
