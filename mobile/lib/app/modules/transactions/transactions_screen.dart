import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/modules/transactions/transactions_controller.dart';
import 'package:mobile/app/theme/app_colors.dart'; // Sayı ve tarih formatlama için
import 'package:mobile/app/widgets/error_view.dart'; // ErrorView widget'ını import et
import 'package:mobile/app/widgets/custom_home_app_bar.dart'; // CustomHomeAppBar widget'ını import et

/// İşlemleri listeleyen ve filtreleyen modern ekran.
class TransactionsScreen extends GetView<TransactionsController> {
  const TransactionsScreen({super.key});

  // Para formatlayıcı
  NumberFormat get currencyFormatter =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  // Kategori ikonunu döndüren yardımcı fonksiyon
  IconData _getCategoryIcon(String? iconCode) {
    return iconCode != null
        ? IconData(int.parse(iconCode), fontFamily: 'MaterialIcons')
        : Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHomeAppBar(
        title: 'İşlemler',
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
            onPressed: () => _showFilterBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: () {
              controller.fetchTransactions(isInitialLoad: false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('İşlemler yenileniyor...'),
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
          // İşlem özeti üst bölüm
          _buildTransactionSummary(),

          // Filtreler ve içerik
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.fetchTransactions,
              child: Obx(() {
                // Yükleme durumu
                if (controller.isLoading.value &&
                    controller.transactionList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Hata durumu
                else if (controller.errorMessage.isNotEmpty &&
                    controller.transactionList.isEmpty) {
                  return ErrorView(
                    message: controller.errorMessage.value,
                    onRetry: () =>
                        controller.fetchTransactions(isInitialLoad: true),
                    isLarge: true,
                  );
                }
                // Ana içerik
                else {
                  return Column(
                    children: [
                      // Aktif filtreleri gösteren alan
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
          ),
        ],
      ),
    );
  }

  /// İşlem özet kartını oluşturur
  Widget _buildTransactionSummary() {
    return Obx(() {
      // Yükleme durumunda özet gösterme
      if (controller.isLoading.value && controller.transactionList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            // Gelir/Gider özeti
            Row(
              children: [
                _buildSummaryItem(
                  title: 'Gelir',
                  amount: controller.totalIncome.value,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.success,
                  flex: 1,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                _buildSummaryItem(
                  title: 'Gider',
                  amount: controller.totalExpense.value,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.error,
                  flex: 1,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dönem seçici
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.selectedStartDate.value == null
                        ? 'Tüm Zamanlar'
                        : "${DateFormat('dd MMM', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('dd MMM', 'tr_TR').format(controller.selectedEndDate.value!)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Özet bilgisi oluşturur
  Widget _buildSummaryItem({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                currencyFormatter.format(amount),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Aktif filtreleri gösteren Chip'leri oluşturur
  Widget _buildActiveFiltersChipRow() {
    return Obx(() {
      final List<Widget> chips = [];

      if (controller.selectedAccount.value != null) {
        chips.add(_buildFilterChip(
          label: 'Hesap: ${controller.selectedAccount.value!.name}',
          onDeleted: () => controller.selectAccountFilter(null),
          icon: Icons.account_balance_wallet_outlined,
        ));
      }

      if (controller.selectedCategory.value != null) {
        chips.add(_buildFilterChip(
          label: 'Kategori: ${controller.selectedCategory.value!.name}',
          onDeleted: () => controller.selectCategoryFilter(null),
          icon: Icons.category_outlined,
        ));
      }

      if (controller.selectedType.value != null) {
        chips.add(_buildFilterChip(
          label: controller.selectedType.value == CategoryType.Expense
              ? 'Tip: Gider'
              : 'Tip: Gelir',
          onDeleted: () => controller.selectTypeFilter(null),
          icon: controller.selectedType.value == CategoryType.Expense
              ? Icons.arrow_downward
              : Icons.arrow_upward,
        ));
      }

      if (controller.selectedStartDate.value != null) {
        chips.add(_buildFilterChip(
          label:
              'Tarih: ${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedEndDate.value!)}',
          onDeleted: () {
            controller.selectedStartDate.value = null;
            controller.selectedEndDate.value = null;
            controller.applyFilters();
          },
          icon: Icons.date_range,
        ));
      }

      if (chips.isEmpty) {
        return const SizedBox.shrink();
      }

      // Kaydırılabilir filtre chip'leri
      return Container(
        height: 60,
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

  /// Özel tasarlanmış filtre chip'i
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
    required IconData icon,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onDeleted: onDeleted,
      deleteIconColor: Colors.black54,
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  /// İşlem listesini oluşturur - Grup başlıklarıyla
  Widget _buildTransactionList() {
    return Obx(() {
      // Boş liste durumu
      if (controller.transactionList.isEmpty && !controller.isLoading.value) {
        return _buildEmptyState();
      }

      // Tarih gruplarına göre işlemleri ayır
      final Map<String, List<TransactionModel>> groupedTransactions = {};
      for (var transaction in controller.transactionList) {
        final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR')
            .format(transaction.transactionDate);
        if (!groupedTransactions.containsKey(dateStr)) {
          groupedTransactions[dateStr] = [];
        }
        groupedTransactions[dateStr]!.add(transaction);
      }

      // Tarih gruplarını sırala (en yeni en üstte)
      final sortedDates = groupedTransactions.keys.toList()
        ..sort((a, b) {
          final dateA = DateFormat('dd MMMM yyyy', 'tr_TR').parse(a);
          final dateB = DateFormat('dd MMMM yyyy', 'tr_TR').parse(b);
          return dateB.compareTo(dateA);
        });

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: sortedDates.length + (controller.hasMoreData.value ? 1 : 0),
        itemBuilder: (context, index) {
          // Listenin sonuna geldik mi?
          if (index == sortedDates.length) {
            return controller.isLoadingMore.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const SizedBox.shrink();
          }

          // Grup başlığı ve o gruba ait işlemler
          final dateStr = sortedDates[index];
          final transactionsInGroup = groupedTransactions[dateStr]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarih başlığı
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Bu tarihe ait işlemler
              ...transactionsInGroup
                  .map((transaction) =>
                      _buildTransactionCard(context, transaction))
                  .toList(),
            ],
          );
        },
      );
    });
  }

  /// Boş durum ekranı
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sync_alt_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'İşlem Bulunamadı',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Gösterilecek işlem bulunamadı. Filtre ayarlarını değiştirebilir veya yeni işlem ekleyebilirsiniz.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: controller.goToAddTransaction,
            icon: const Icon(Icons.add),
            label: const Text('İşlem Ekle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tek bir işlem kartını oluşturur
  Widget _buildTransactionCard(
      BuildContext context, TransactionModel transaction) {
    final bool isIncome = transaction.categoryType == CategoryType.Income;
    final Color amountColor = isIncome ? AppColors.success : AppColors.error;
    final IconData categoryIcon = _getCategoryIcon(transaction.categoryIcon);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => controller.goToEditTransaction(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Kategori ikonu
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcon,
                  color: amountColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // İşlem bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.categoryName,
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.accountName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (transaction.notes != null &&
                            transaction.notes!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.notes,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              transaction.notes!,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // İşlem tutarı
              Text(
                currencyFormatter.format(transaction.amount),
                style: Get.textTheme.titleMedium?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Filtreleme seçeneklerini gösteren Bottom Sheet'i açar
  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('İşlem Filtreleri',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // İşlem Tipi Seçimi (Gelir/Gider)
              _buildFilterSectionTitle(context, 'İşlem Tipi'),
              Obx(() => Row(
                    children: [
                      _buildTypeFilterButton(
                        title: 'Tümü',
                        icon: Icons.sync_alt_rounded,
                        isSelected: controller.selectedType.value == null,
                        onTap: () => controller.selectTypeFilter(null),
                      ),
                      const SizedBox(width: 12),
                      _buildTypeFilterButton(
                        title: 'Gelir',
                        icon: Icons.arrow_upward,
                        isSelected: controller.selectedType.value ==
                            CategoryType.Income,
                        onTap: () =>
                            controller.selectTypeFilter(CategoryType.Income),
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      _buildTypeFilterButton(
                        title: 'Gider',
                        icon: Icons.arrow_downward,
                        isSelected: controller.selectedType.value ==
                            CategoryType.Expense,
                        onTap: () =>
                            controller.selectTypeFilter(CategoryType.Expense),
                        color: AppColors.error,
                      ),
                    ],
                  )),

              const SizedBox(height: 24),

              // Tarih Aralığı
              _buildFilterSectionTitle(context, 'Tarih Aralığı'),
              _buildFilterOption(
                  leadingIcon: Icons.date_range_outlined,
                  title: 'Tarih Aralığı Seçin',
                  subtitle: Obx(() => Text(controller.selectedStartDate.value ==
                          null
                      ? 'Tüm Tarihler'
                      : '${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedStartDate.value!)} - ${DateFormat('dd/MM/yy', 'tr_TR').format(controller.selectedEndDate.value!)}')),
                  onTap: () {
                    Get.back();
                    controller.selectDateRange(context);
                  }),

              // Hızlı Tarih Aralığı Butonları
              _buildQuickDateFilterButtons(),

              const SizedBox(height: 16),

              // Hesap Seçimi
              _buildFilterSectionTitle(context, 'Hesap'),
              Obx(() => _buildDropdown<AccountModel?>(
                    value: controller.selectedAccount.value,
                    items: [
                      const DropdownMenuItem<AccountModel?>(
                        value: null,
                        child: Text('Tüm Hesaplar'),
                      ),
                      ...controller.filterAccounts
                          .map((account) => DropdownMenuItem<AccountModel>(
                                value: account,
                                child: Text(account.name,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                    ],
                    onChanged: controller.selectAccountFilter,
                    icon: Icons.account_balance_wallet_outlined,
                  )),

              const SizedBox(height: 16),

              // Kategori Seçimi
              _buildFilterSectionTitle(context, 'Kategori'),
              Obx(() => _buildDropdown<CategoryModel?>(
                    value: controller.selectedCategory.value,
                    items: [
                      const DropdownMenuItem<CategoryModel?>(
                        value: null,
                        child: Text('Tüm Kategoriler'),
                      ),
                      ...controller.filterCategories
                          .map((category) => DropdownMenuItem<CategoryModel>(
                                value: category,
                                child: Text(category.name,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                    ],
                    onChanged: controller.selectCategoryFilter,
                    icon: Icons.category_outlined,
                  )),

              const SizedBox(height: 24),

              // Sıralama Seçenekleri
              _buildFilterSectionTitle(context, 'Sıralama'),
              _buildSortingOptions(),

              const SizedBox(height: 24),

              // Eylem Butonları
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Filtreleri Temizle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Uygula'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Hızlı tarih filtreleme butonları
  Widget _buildQuickDateFilterButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildQuickDateButton(
              'Bugün', () => controller.setQuickDateFilter('today')),
          _buildQuickDateButton(
              'Dün', () => controller.setQuickDateFilter('yesterday')),
          _buildQuickDateButton(
              'Bu Hafta', () => controller.setQuickDateFilter('thisWeek')),
          _buildQuickDateButton(
              'Bu Ay', () => controller.setQuickDateFilter('thisMonth')),
          _buildQuickDateButton(
              'Geçen Ay', () => controller.setQuickDateFilter('lastMonth')),
          _buildQuickDateButton(
              'Son 3 Ay', () => controller.setQuickDateFilter('last3Months')),
        ],
      ),
    );
  }

  /// Hızlı tarih filtre butonu
  Widget _buildQuickDateButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        onTap();
        Get.back();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          color: AppColors.primary.withOpacity(0.05),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// Sıralama seçenekleri
  Widget _buildSortingOptions() {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSortOptionChip(
              label: 'Tarih ↓',
              isSelected: controller.sortCriteria.value == 'date_desc',
              onSelected: () => controller.setSortingCriteria('date_desc'),
            ),
            _buildSortOptionChip(
              label: 'Tarih ↑',
              isSelected: controller.sortCriteria.value == 'date_asc',
              onSelected: () => controller.setSortingCriteria('date_asc'),
            ),
            _buildSortOptionChip(
              label: 'Tutar ↓',
              isSelected: controller.sortCriteria.value == 'amount_desc',
              onSelected: () => controller.setSortingCriteria('amount_desc'),
            ),
            _buildSortOptionChip(
              label: 'Tutar ↑',
              isSelected: controller.sortCriteria.value == 'amount_asc',
              onSelected: () => controller.setSortingCriteria('amount_asc'),
            ),
          ],
        ));
  }

  /// Sıralama seçeneği chip'i
  Widget _buildSortOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelected();
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  /// Filtre seçeneği
  Widget _buildFilterOption({
    required IconData leadingIcon,
    required String title,
    required Widget subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          leadingIcon,
          color: AppColors.primary,
        ),
      ),
      title: Text(title),
      subtitle: subtitle,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// Filtre bölüm başlığını oluşturur
  Widget _buildFilterSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Özel tasarlanmış dropdown
  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          hint: const Text('Seçiniz'),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// İşlem tipi filtre butonlarını oluşturur
  Widget _buildTypeFilterButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? AppColors.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? buttonColor.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? buttonColor : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? buttonColor : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? buttonColor : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
