import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/budgets/Widgets/budget_card.dart';
import 'package:mobile/app/modules/budgets/Widgets/month_selector.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/widgets/error_view.dart';
import 'package:mobile/app/widgets/custom_home_app_bar.dart';

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
      appBar: CustomHomeAppBar(
        title: 'Bütçeler',
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrele',
            onPressed: () {
              // TODO: Filtreleme dialogunu göster
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filtreleme özelliği henüz yapım aşamasında'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: () {
              controller.refreshBudgets();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bütçeler yenileniyor...'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Ay/Yıl seçici
          MonthSelector(
              controller: controller, formatMonth: _formatMonth), // Yeni widget
          // Bütçe listesi
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshBudgets,
              child: Obx(() {
                // State değişikliklerini dinle
                // 1. Yüklenme Durumu
                if (controller.isLoading.value &&
                    controller.budgetList.isEmpty) {
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
                else if (controller.budgetList.isEmpty &&
                    !controller.isLoading.value) {
                  // ErrorView.noData widget'ını kullan
                  return ErrorView.noData(
                    message: 'Bu dönem için bütçe bulunmuyor.',
                    onRetry: controller.refreshBudgets,
                    onAdd: controller.goToAddBudget,
                  );
                }
                // 4. Bütçe Listesi
                else {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: controller.budgetList.length,
                    itemBuilder: (context, index) {
                      final budget = controller.budgetList[index];
                      return BudgetCard(
                        // Yeni widget çağrısı
                        budget: budget,
                        currencyFormatter: currencyFormatter,
                        controller: controller, // Controller eklendi
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
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
