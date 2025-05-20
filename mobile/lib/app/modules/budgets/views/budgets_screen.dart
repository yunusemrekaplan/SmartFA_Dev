import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/modules/budgets/widgets/budgets/active_filters_bar/active_filters_bar.dart';
import 'package:mobile/app/modules/budgets/widgets/budgets/budget_card/budget_card.dart';
import 'package:mobile/app/modules/budgets/widgets/budgets/budget_filter_bottom_sheet/budget_filter_bottom_sheet.dart';
import 'package:mobile/app/modules/budgets/widgets/budgets/month_selector.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/widgets/content_view.dart';
import 'package:mobile/app/widgets/empty_state_view.dart';
import 'package:mobile/app/widgets/custom_app_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Kullanıcının bütçelerini listeleyen ekran.
class BudgetsScreen extends GetView<BudgetsController> {
  const BudgetsScreen({super.key});

  // Para formatlayıcı
  NumberFormat get currencyFormatter =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

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
      appBar: CustomAppBar(
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
            final bool hasActiveFilters =
                controller.activeFilter.value != BudgetFilterType.all ||
                    controller.selectedCategoryIds.isNotEmpty ||
                    controller.searchQuery.isNotEmpty;

            return IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: hasActiveFilters ? AppColors.primary : null,
              ),
              tooltip: 'Filtrele',
              onPressed: () =>
                  BudgetFilterBottomSheet.show(context, controller),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ay/Yıl seçici
            MonthSelector(controller: controller, formatMonth: _formatMonth),

            // Aktif filtre göstergesi
            ActiveFiltersBar(controller: controller),

            // Bütçe listesi - RefreshableContentView kullanarak
            Expanded(
              child: Obx(() {
                return ContentView<dynamic>(
                  isLoading: controller.isLoading,
                  errorMessage: controller.errorMessage,
                  items: controller.filteredBudgetList,
                  contentPadding: const EdgeInsets.all(16.0),
                  showLoadingOverlay: true,
                  emptyStateView: controller.budgetList.isEmpty
                      ? EmptyStateView(
                          title: 'Bütçe Bulunamadı',
                          message: 'Henüz bütçeniz yok.',
                          actionText: 'Bütçe Ekle',
                          onAction: controller.goToAddBudget,
                          icon: Icons.pie_chart_rounded,
                        )
                      : EmptyStateView(
                          title: 'Bütçe Bulunamadı',
                          message: 'Seçilen filtrelere uygun bütçe bulunamadı.',
                          actionText: 'Filtreleri Sıfırla',
                          onAction: controller.resetFilters,
                          icon: Icons.filter_alt_off_rounded,
                          actionIcon: Icons.filter_alt_off_rounded,
                        ),
                  contentView: _buildBudgetList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetList() {
    return ListView.separated(
      // RefreshableContentView kendi padding'ini uygulayacak
      padding: EdgeInsets.zero,
      // ListView'ın boyutunu içeriğine göre sınırlandırıyoruz
      shrinkWrap: true,
      // Üst scrollview'in scrollunu kullanacağız
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
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
}
