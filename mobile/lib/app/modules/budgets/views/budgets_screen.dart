import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/modules/budgets/widgets/budgets/active_filters_bar/active_filters_bar.dart';
import 'package:mobile/app/modules/budgets/widgets/budgets/budget_card/budget_card.dart';
import 'package:mobile/app/modules/budgets/widgets/budgets/budget_filter_bottom_sheet/budget_filter_bottom_sheet.dart';
import 'package:mobile/app/modules/budgets/widgets/budgets/month_selector.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/widgets/error_view.dart';
import 'package:mobile/app/widgets/custom_home_app_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Kullanıcının bütçelerini listeleyen ekran.
class BudgetsScreen extends GetView<BudgetsController> {
  const BudgetsScreen({super.key});

  // Para formatlayıcı
  NumberFormat get currencyFormatter => NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  // Ay adını formatlayıcı
  String _formatMonth(DateTime date) {
    // Türkçe ay isimleri
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHomeAppBar(
        title: 'Bütçeler',
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          Obx(() {
            // Aktif filtre varsa butonları belirginleştir
            final bool hasActiveFilters = controller.activeFilter.value != BudgetFilterType.all ||
                controller.selectedCategoryIds.isNotEmpty ||
                controller.searchQuery.isNotEmpty;

            return IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: hasActiveFilters ? AppColors.primary : null,
              ),
              tooltip: 'Filtrele',
              onPressed: () => BudgetFilterBottomSheet.show(context, controller),
            );
          }),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Bütçe Ekle',
            onPressed: () {
              controller.goToAddBudget();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Ay/Yıl seçici
          MonthSelector(controller: controller, formatMonth: _formatMonth),

          // Aktif filtre göstergesi
          ActiveFiltersBar(controller: controller),

          // Bütçe listesi
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshBudgets,
              child: Obx(() {
                // State değişikliklerini dinle
                // 1. Yüklenme Durumu
                if (controller.isLoading.value && controller.budgetList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2. Hata Durumu
                else if (controller.errorMessage.isNotEmpty) {
                  // ErrorView widget'ını kullan
                  return ErrorView(
                    message: controller.errorMessage.value,
                    onRetry: controller.refreshBudgets,
                    isLarge: true,
                  );
                }
                // 3. Boş Liste Durumu
                else if (controller.filteredBudgetList.isEmpty && !controller.isLoading.value) {
                  // Filtre uygulanmış ve sonuç boş mu kontrolü
                  if (controller.budgetList.isNotEmpty) {
                    // Filtreleme sonucu boş
                    return EmptyStateView(
                      title: 'Bütçe Bulunamadı',
                      message: 'Seçilen filtrelere uygun bütçe bulunamadı.',
                      actionText: 'Filtreleri Sıfırla',
                      onAction: controller.resetFilters,
                      icon: Icons.filter_alt_off_rounded,
                      actionIcon: Icons.filter_alt_off_rounded,
                    );
                  }

                  // Veri yok (filtresiz)
                  return EmptyStateView(
                    title: 'Bütçe Bulunamadı',
                    message: 'Henüz bütçeniz yok.',
                    actionText: 'Bütçe Ekle',
                    onAction: () {
                      controller.goToAddBudget();
                    },
                    icon: Icons.pie_chart_rounded,
                  );
                }
                // 4. Bütçe Listesi
                else {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: controller.filteredBudgetList.length,
                    itemBuilder: (context, index) {
                      final budget = controller.filteredBudgetList[index];
                      return BudgetCard(
                        budget: budget,
                        currencyFormatter: currencyFormatter,
                        controller: controller,
                      ).animate().fadeIn(
                            duration: 300.ms,
                            delay: Duration(milliseconds: 50 * index),
                          );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}
