import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Modern ay/yıl seçici widget'ı
class MonthSelector extends StatelessWidget {
  final BudgetsController controller;
  final String Function(DateTime) formatMonth;

  const MonthSelector({
    super.key,
    required this.controller,
    required this.formatMonth,
  });

  /// Ay seçici alt sayfa
  void _showMonthPicker(BuildContext context) {
    final DateTime currentPeriod = controller.selectedPeriod.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Tutma çubuğu
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Başlık
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Bütçe Dönemini Seçin",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),

              // Aylar listesi
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: 12, // Son 6 ay + gelecek 5 ay + mevcut ay
                  itemBuilder: (context, index) {
                    // Mevcut aydan 6 ay öncesinden başlayarak 12 ay listele
                    final month = DateTime(
                      currentPeriod.year +
                          ((currentPeriod.month + index - 7) ~/ 12),
                      ((currentPeriod.month + index - 7) % 12) + 1,
                    );

                    final isSelected = month.month == currentPeriod.month &&
                        month.year == currentPeriod.year;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${month.month}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                            ),
                          ),
                        ),
                        title: Text(
                          formatMonth(month),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () {
                          controller.changePeriod(month);
                          Navigator.pop(context);
                        },
                      ),
                    ).animate().fadeIn(
                          duration: 200.ms,
                          delay: Duration(milliseconds: 30 * index),
                        );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
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
              child: const Icon(Icons.chevron_left),
            ),
            onPressed: controller.goToPreviousMonth,
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showMonthPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          formatMonth(controller.selectedPeriod.value),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    )),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: -0.2,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
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
              child: const Icon(Icons.chevron_right),
            ),
            onPressed: controller.goToNextMonth,
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
