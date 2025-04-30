import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/modules/transactions/transactions_controller.dart';
import 'package:mobile/app/theme/app_colors.dart'; // Sayı ve tarih formatlama için

/// İşlemleri listeleyen ve filtreleyen ekran.
class TransactionsScreen extends GetView<TransactionsController> {
  const TransactionsScreen({super.key});

  // Para formatlayıcı
  NumberFormat get currencyFormatter => NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  // Kategori ikonunu döndüren yardımcı fonksiyon (Geliştirilmeli)
  IconData _getCategoryIcon(String? iconName) {
    // TODO: iconName string'ine göre FontAwesome veya Material ikonlarını eşleştir.
    // Örnek basit eşleştirme:
    if (iconName == null) return Icons.category_outlined;
    if (iconName.contains('cart')) return Icons.shopping_cart_outlined;
    if (iconName.contains('invoice')) return Icons.receipt_long_outlined;
    if (iconName.contains('bus')) return Icons.directions_bus_outlined;
    if (iconName.contains('utensils')) return Icons.restaurant_outlined;
    if (iconName.contains('home')) return Icons.home_outlined;
    if (iconName.contains('heartbeat')) return Icons.monitor_heart_outlined;
    if (iconName.contains('graduation')) return Icons.school_outlined;
    if (iconName.contains('tshirt')) return Icons.checkroom_outlined;
    if (iconName.contains('film')) return Icons.theaters_outlined;
    if (iconName.contains('briefcase')) return Icons.business_center_outlined;
    if (iconName.contains('usd')) return Icons.attach_money_outlined;
    return Icons.category_outlined; // Varsayılan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlemler'),
        centerTitle: true,
        actions: [
          // Filtreleme Butonu
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrele',
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchTransactions, // Controller'da refreshTransactions olmalı
        child: Obx(() {
          // Controller'daki state değişikliklerini dinle
          // --- Yüklenme Durumu ---
          if (controller.isLoading.value && controller.transactionList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- Hata Durumu ---
          else if (controller.errorMessage.isNotEmpty && controller.transactionList.isEmpty) {
            return _buildErrorWidget(context); // Hata widget'ını göster
          }
          // --- Boş Liste veya Veri Durumu ---
          else {
            return Column(
              children: [
                // Aktif filtreleri gösteren bir alan (Opsiyonel)
                _buildActiveFiltersChipRow(),

                // İşlem listesi
                Expanded(
                  child: _buildTransactionList(),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  /// Aktif filtreleri gösteren Chip'leri oluşturur (varsa).
  Widget _buildActiveFiltersChipRow() {
    return Obx(() {
      final List<Widget> chips = [];
      if (controller.selectedAccount.value != null) {
        chips.add(Chip(
          label: Text('Hesap: ${controller.selectedAccount.value!.name}'),
          onDeleted: () => controller.selectAccountFilter(null), // Filtreyi kaldır
          deleteIconColor: Colors.black54,
          backgroundColor: Colors.grey.shade200,
        ));
      }
      if (controller.selectedCategory.value != null) {
        chips.add(Chip(
          label: Text('Kategori: ${controller.selectedCategory.value!.name}'),
          onDeleted: () => controller.selectCategoryFilter(null),
          deleteIconColor: Colors.black54,
          backgroundColor: Colors.grey.shade200,
        ));
      }
      if (controller.selectedType.value != null) {
        chips.add(Chip(
          label: Text(
              controller.selectedType.value == CategoryType.Expense ? 'Tip: Gider' : 'Tip: Gelir'),
          onDeleted: () => controller.selectTypeFilter(null),
          deleteIconColor: Colors.black54,
          backgroundColor: Colors.grey.shade200,
        ));
      }
      if (controller.selectedStartDate.value != null) {
        chips.add(Chip(
          label: Text(
              'Tarih: ${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedEndDate.value!)}'),
          onDeleted: () {
            controller.selectedStartDate.value = null;
            controller.selectedEndDate.value = null;
            controller.applyFilters();
          },
          deleteIconColor: Colors.black54,
          backgroundColor: Colors.grey.shade200,
        ));
      }

      if (chips.isEmpty) {
        return const SizedBox.shrink(); // Filtre yoksa boşluk
      }

      // Kaydırılabilir filtre chip'leri
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: chips.length,
          itemBuilder: (context, index) => chips[index],
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      );
    });
  }

  /// İşlem listesini ve sonsuz kaydırmayı yöneten widget.
  Widget _buildTransactionList() {
    return Obx(() {
      // Listenin kendisini de Obx ile sarmak güncellemeler için iyi olabilir
      // --- Boş Liste Durumu (Filtre uygulandıktan sonra) ---
      if (controller.transactionList.isEmpty && !controller.isLoading.value) {
        return _buildEmptyListWidget(Get.context!); // Get.context! kullanıldı
      }
      // --- Liste Gösterimi ---
      else {
        return ListView.separated(
          controller: controller.scrollController,
          // ScrollController eklendi
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          // Listenin uzunluğu + yükleme indicator'ı için 1 (eğer daha fazla veri varsa)
          itemCount: controller.transactionList.length + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            // Listenin sonuna geldik mi ve daha fazla veri var mı?
            if (index == controller.transactionList.length) {
              // Yükleme indicator'ını göster
              return controller.isLoadingMore.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : const SizedBox.shrink(); // Yüklenmiyorsa boşluk
            }
            // Normal işlem öğesi
            final transaction = controller.transactionList[index];
            return _buildTransactionTile(context, transaction);
          },
          separatorBuilder: (context, index) => Divider(
              height: 1, indent: 72, color: Colors.grey.shade200), // Leading ikon hizasından başlar
        );
      }
    });
  }

  /// Tek bir işlem öğesini (ListTile) oluşturur.
  Widget _buildTransactionTile(BuildContext context, TransactionModel transaction) {
    final bool isIncome = transaction.categoryType == CategoryType.Income;
    final Color amountColor = isIncome ? AppColors.success : Theme.of(context).colorScheme.error;
    final IconData categoryIcon = _getCategoryIcon(transaction.categoryIcon);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      leading: CircleAvatar(
        backgroundColor: amountColor.withOpacity(0.1),
        child: Icon(categoryIcon, size: 20, color: amountColor),
      ),
      title: Text(
        transaction.categoryName,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w500), // titleMedium daha uygun olabilir
      ),
      subtitle: Text(
        transaction.accountName,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currencyFormatter.format(transaction.amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  // titleMedium daha uygun olabilir
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            DateFormat('dd MMM yy', 'tr_TR').format(transaction.transactionDate),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () {
        controller.goToEditTransaction(transaction);
      },
      onLongPress: () {
        controller.deleteTransaction(transaction.id);
      },
    );
  }

  /// Hata durumunda gösterilecek widget.
  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              onPressed: () => controller.fetchTransactions(isInitialLoad: true),
            )
          ],
        ),
      ),
    );
  }

  /// İşlem listesi boş olduğunda gösterilecek widget.
  Widget _buildEmptyListWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('Gösterilecek işlem bulunamadı.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          // Eğer filtre aktifse filtreleri temizle butonu göster
          if (controller.selectedAccount.value != null ||
              controller.selectedCategory.value != null ||
              controller.selectedStartDate.value != null ||
              controller.selectedType.value != null)
            TextButton(
              onPressed: controller.clearFilters,
              child: const Text('Filtreleri Temizle'),
            ),
        ],
      ),
    );
  }

  /// Filtreleme seçeneklerini gösteren Bottom Sheet'i açar.
  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        // Yüksekliği içeriğe göre ayarla veya sabit bir değer ver
        // height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          // İçerik sığmazsa kaydırılabilir yap
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlan
            children: [
              Text('Filtrele', style: Theme.of(context).textTheme.headlineSmall),
              const Divider(height: 24),

              // --- Filtre Seçenekleri ---

              // Tarih Aralığı
              ListTile(
                  leading: const Icon(Icons.date_range_outlined),
                  title: const Text('Tarih Aralığı'),
                  subtitle: Obx(() => Text(controller.selectedStartDate.value == null
                      ? 'Seçilmedi'
                      : '${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedEndDate.value!)}')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Get.back(); // Önce bottom sheet'i kapat
                    controller.selectDateRange(context); // Sonra date picker'ı aç
                  }),
              const Divider(height: 1, indent: 16),

              // Hesap Seçimi
              Obx(() => DropdownButtonFormField<AccountModel?>(
                    value: controller.selectedAccount.value,
                    decoration: const InputDecoration(
                      labelText: 'Hesap',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      border: InputBorder.none, // Kenarlıkları kaldır
                      contentPadding: EdgeInsets.zero, // İç boşluğu sıfırla
                    ),
                    hint: const Text('Tüm Hesaplar'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<AccountModel?>(
                        value: null,
                        child: Text('Tüm Hesaplar'),
                      ),
                      ...controller.filterAccounts.map((account) {
                        return DropdownMenuItem<AccountModel>(
                          value: account,
                          child: Text(account.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ],
                    onChanged: controller.selectAccountFilter, // Değişiklikte controller'ı çağır
                  )),
              const Divider(height: 1, indent: 16),

              // Kategori Seçimi
              Obx(() => DropdownButtonFormField<CategoryModel?>(
                    value: controller.selectedCategory.value,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    hint: const Text('Tüm Kategoriler'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<CategoryModel?>(
                        value: null,
                        child: Text('Tüm Kategoriler'),
                      ),
                      ...controller.filterCategories.map((category) {
                        return DropdownMenuItem<CategoryModel>(
                          value: category,
                          child: Text(category.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ],
                    onChanged: controller.selectCategoryFilter,
                  )),
              const Divider(height: 1, indent: 16),

              // Tip Seçimi (Gelir/Gider)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Obx(() => SegmentedButton<CategoryType?>(
                      segments: const [
                        ButtonSegment<CategoryType?>(
                            value: null, label: Text('Tümü'), icon: Icon(Icons.clear_all)),
                        ButtonSegment<CategoryType?>(
                            value: CategoryType.Expense,
                            label: Text('Gider'),
                            icon: Icon(Icons.arrow_downward)),
                        ButtonSegment<CategoryType?>(
                            value: CategoryType.Income,
                            label: Text('Gelir'),
                            icon: Icon(Icons.arrow_upward)),
                      ],
                      selected: {controller.selectedType.value},
                      onSelectionChanged: (Set<CategoryType?> newSelection) {
                        controller.selectTypeFilter(newSelection.first);
                      },
                      // Style ayarları tema üzerinden yapılabilir
                      style: SegmentedButton.styleFrom(
                          // selectedBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          // selectedForegroundColor: Theme.of(context).colorScheme.primary,
                          ),
                    )),
              ),

              // --- Eylem Butonları ---
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.clearFilters();
                      Get.back(); // Bottom sheet'i kapat
                    },
                    child: const Text('Filtreleri Temizle'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Filtreler zaten seçim anında uygulanıyor (applyFilters çağrılıyor)
                      Get.back(); // Bottom sheet'i kapat
                    },
                    child: const Text('Kapat'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      // isScrollControlled: true, // İçerik sığmazsa bottom sheet'in yüksekliğini artırır
      // backgroundColor: Colors.transparent, // Arkaplanı transparan yapıp Container'a renk vermek
      // barrierColor: Colors.black45, // Arka plan karartma rengi
    );
    print('Filter button pressed');
  }
}
