import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/modules/budgets/budgets_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: controller.goToPreviousMonth,
                ),
                Obx(() => GestureDetector(
                      onTap: () => _showMonthPicker(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _formatMonth(controller.selectedPeriod.value),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    )),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: controller.goToNextMonth,
                ),
              ],
            ),
          ),
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
                      return _buildBudgetTile(context, budget);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10), // Kartlar arası boşluk
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Ay seçici diyalog
  void _showMonthPicker(BuildContext context) async {
    final DateTime currentPeriod = controller.selectedPeriod.value;

    // Ay seçici, burada basit bir diyalog kullanılıyor
    // Gerçek uygulamada date_picker veya özel bir widget kullanılabilir
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Dönem Seçin",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    // 6 ay öncesi ve 5 ay sonrası
                    final month = DateTime(
                      currentPeriod.year +
                          ((currentPeriod.month + index - 6) ~/ 12),
                      ((currentPeriod.month + index - 6) % 12) + 1,
                    );

                    return ListTile(
                      title: Text(_formatMonth(month)),
                      selected: month.month == currentPeriod.month &&
                          month.year == currentPeriod.year,
                      selectedTileColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      onTap: () {
                        controller.changePeriod(month);
                        Navigator.pop(context);
                      },
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

  /// Tek bir bütçe öğesini gösteren kart widget'ını oluşturur.
  Widget _buildBudgetTile(BuildContext context, BudgetModel budget) {
    // İlerleme çubuğu için yüzdelik değer (0.0-1.0 arasında)
    final double spentPercentage =
        budget.amount > 0 ? budget.spentAmount / budget.amount : 0;

    // İlerleme çubuğu rengi (kırmızı: aşım, yeşilden turuncuya: normal)
    Color progressColor;
    if (spentPercentage >= 1.0) {
      progressColor = AppColors.error; // Bütçeyi aşmış
    } else if (spentPercentage >= 0.8) {
      progressColor = Colors.orange; // Bütçe limitine yaklaşıyor
    } else {
      progressColor = Colors.green; // Normal harcama
    }

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
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
                      CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                        child: budget.categoryIcon != null &&
                                budget.categoryIcon!.isNotEmpty
                            ? Icon(
                                IconData(int.parse(budget.categoryIcon!),
                                    fontFamily: 'MaterialIcons'),
                                color: Theme.of(context).colorScheme.primary)
                            : Icon(Icons.category_outlined,
                                color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          budget.categoryName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          overflow: TextOverflow.ellipsis,
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
                          });
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Düzenle')),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                          leading:
                              Icon(Icons.delete_outline, color: Colors.red),
                          title:
                              Text('Sil', style: TextStyle(color: Colors.red))),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bütçe ilerleme çubuğu
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: spentPercentage.clamp(0.0,
                    1.0), // 1.0'dan büyük olsa bile gösterge 1.0'da sabit kalır
                backgroundColor: Colors.grey.shade200,
                color: progressColor,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            // Bütçe tutar bilgileri
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Harcanan miktar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harcanan',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(budget.spentAmount),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: spentPercentage >= 1.0
                                ? AppColors.error
                                : Colors.black87,
                          ),
                    ),
                  ],
                ),
                // Kalan miktar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Kalan / Toplam',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyFormatter.format(budget.remainingAmount)} / ${currencyFormatter.format(budget.amount)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: budget.remainingAmount < 0
                                ? AppColors.error
                                : Colors.black87,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
