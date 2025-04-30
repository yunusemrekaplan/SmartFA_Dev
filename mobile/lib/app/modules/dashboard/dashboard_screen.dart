

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/modules/dashboard/dashboard_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Dashboard ekranı, finansal özeti gösterir.
class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  // Sayı formatlayıcı (para birimi için)
  // Intl paketinin locale ayarlarının main.dart veya başlangıçta yapıldığını varsayıyoruz.
  NumberFormat get currencyFormatter =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺'); // Türkçe locale ve TL simgesi

  @override
  Widget build(BuildContext context) {
    // GetView kullandığımız için controller'a doğrudan 'controller' ile erişebiliriz.
    // Binding'in HomeBinding veya DashboardBinding içinde doğru yapıldığından emin olunmalı.
    // Get.find<DashboardController>(); // Alternatif erişim

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        // Opsiyonel: AppBar'a eylem butonları eklenebilir (örn: bildirimler)
        actions: [
          IconButton(
            // Yenileme butonu
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          )
        ],
      ),
      // Pull-to-refresh ekleyelim
      body: RefreshIndicator(
        onRefresh: controller.refreshData, // Controller'daki yenileme metodunu çağır
        child: Obx(() { // Controller'daki state değişikliklerini dinle
          // 1. Yüklenme Durumu
          if (controller.isLoading.value && controller.recentTransactions.isEmpty) {
            // İlk yüklemede merkezi bir indicator göster
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Hata Durumu (Eğer veri yüklenemediyse ama belki bazıları yüklendi)
          // Hata mesajını göstermenin farklı yolları olabilir (örn: Snackbar)
          // Burada sadece ana içeriği göstermeye devam edip, hatayı başka yerde gösterebiliriz.
          // Veya hata varsa komple hata ekranı gösterebiliriz:
          /*
          else if (controller.errorMessage.isNotEmpty && controller.recentTransactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
                       onPressed: controller.refreshData,
                     )
                  ],
                ),
              ),
            );
          }
          */
          // 3. Veri Gösterimi (Hata olsa bile yüklenebilen verileri göster)
          else {
            // Kaydırılabilir içerik
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Yükleniyor indicator'ı (Pull-to-refresh dışında, ilk yüklemeden sonra)
                if (controller.isLoading.value)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Center(child: LinearProgressIndicator()),
                  ),

                // Hata mesajı (eğer varsa, listenin başında gösterilebilir)
                if (controller.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // --- Bakiye Özeti Kartı ---
                _buildBalanceCard(context),
                const SizedBox(height: 24.0),

                // --- Bütçe Özetleri Bölümü ---
                _buildBudgetSection(context),
                const SizedBox(height: 24.0),

                // --- Son İşlemler Bölümü ---
                _buildRecentTransactionsSection(context),
              ],
            );
          }
        }),
      ),
    );
  }

  // --- Yardımcı Widget Metotları ---

  /// Bakiye özetini gösteren kartı oluşturur.
  Widget _buildBalanceCard(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Toplam Bakiye',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8.0),
            // Obx ile toplam bakiyeyi dinle
            Obx(() => Text(
              currencyFormatter.format(controller.totalBalance.value),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Bütçe özetlerini gösteren bölümü oluşturur.
  Widget _buildBudgetSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bu Ayın Bütçeleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            // Opsiyonel: Tüm bütçeleri görme butonu
            // TextButton(
            //   onPressed: () { /* Bütçeler ekranına git */ },
            //   child: const Text('Tümü'),
            // )
          ],
        ),
        const SizedBox(height: 12.0),
        // Obx ile bütçe listesini dinle
        Obx(() {
          // Yükleniyorsa veya hata varsa farklı bir gösterim yapılabilir
          if (controller.budgetSummaries.isEmpty && !controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: Text('Bu ay için bütçe tanımlanmamış.', style: TextStyle(color: Colors.grey))),
            );
          }
          if (controller.budgetSummaries.isEmpty && controller.isLoading.value) {
            return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(strokeWidth: 2,)));
          }
          // Yatay kaydırılabilir liste
          return SizedBox(
            height: 120, // Yüksekliği ayarla
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.budgetSummaries.length,
              itemBuilder: (context, index) {
                final budget = controller.budgetSummaries[index];
                return _buildBudgetCard(context, budget);
              },
            ),
          );
        }),
      ],
    );
  }

  /// Tek bir bütçe kartını oluşturur.
  Widget _buildBudgetCard(BuildContext context, BudgetModel budget) {
    // Harcanan / Toplam oranını hesapla
    final double spentRatio = (budget.amount > 0) ? (budget.spentAmount / budget.amount) : 0.0;
    // Renkleri orana göre belirle
    final Color progressColor = spentRatio > 1.0 ? AppColors.error : (spentRatio > 0.8 ? AppColors.warning : AppColors.primary);

    return Container(
      width: 160, // Kart genişliği biraz artırıldı
      margin: const EdgeInsets.only(right: 12.0),
      child: Card(
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Dikeyde boşlukları ayarla
            children: [
              Row(
                children: [
                  // Kategori ikonu (Gerçek ikon için IconData.tryParse veya map kullanılabilir)
                  Icon(
                    // Örnek ikon eşleştirme (daha iyi bir yöntem gerekebilir)
                      budget.categoryIcon != null && budget.categoryIcon!.contains('cart') ? Icons.shopping_cart_outlined :
                      budget.categoryIcon != null && budget.categoryIcon!.contains('invoice') ? Icons.receipt_long_outlined :
                      budget.categoryIcon != null && budget.categoryIcon!.contains('bus') ? Icons.directions_bus_outlined :
                      budget.categoryIcon != null && budget.categoryIcon!.contains('utensils') ? Icons.restaurant_outlined :
                      Icons.category_outlined, // Varsayılan
                      size: 18,
                      color: Theme.of(context).colorScheme.primary
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      budget.categoryName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // const Spacer(), // MainAxisAlignment.spaceBetween kullanıldığı için gerek yok

              // Harcama ve progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Kalanı veya aşılanı göstermek daha anlamlı olabilir
                    spentRatio <= 1.0
                        ? '${currencyFormatter.format(budget.remainingAmount)} kaldı'
                        : '${currencyFormatter.format(budget.spentAmount - budget.amount)} aşıldı',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: spentRatio > 1.0 ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  LinearProgressIndicator(
                    value: spentRatio.clamp(0.0, 1.0), // 0 ile 1 arasında sınırla
                    backgroundColor: progressColor.withOpacity(0.2), // Arkaplanı daha soluk yap
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Limit: ${currencyFormatter.format(budget.amount)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Son işlemleri gösteren bölümü oluşturur.
  Widget _buildRecentTransactionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son İşlemler',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            // Opsiyonel: Tüm işlemleri görme butonu
            TextButton(
              onPressed: () {
                // TODO: İşlemler sekmesine git
                // Eğer HomeScreen içindeyse: controller.changeTabIndex(2);
                // Ayrı sayfaysa: Get.toNamed(AppRoutes.TRANSACTIONS);
                print('Tüm İşlemler Tıklandı');
              },
              child: const Text('Tümü'),
            )
          ],
        ),
        const SizedBox(height: 12.0),
        // Obx ile işlem listesini dinle
        Obx(() {
          if (controller.recentTransactions.isEmpty && !controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: Text('Henüz işlem yapılmamış.', style: TextStyle(color: Colors.grey))),
            );
          }
          if (controller.recentTransactions.isEmpty && controller.isLoading.value) {
            return const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ));
          }
          // Son işlemleri gösteren liste
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Kart rengi veya surface rengi
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentTransactions.length,
              itemBuilder: (context, index) {
                final transaction = controller.recentTransactions[index];
                return _buildTransactionTile(context, transaction);
              },
              separatorBuilder: (context, index) => Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200),
            ),
          );
        }),
      ],
    );
  }

  /// Tek bir işlem öğesini (ListTile) oluşturur.
  Widget _buildTransactionTile(BuildContext context, TransactionModel transaction) {
    final bool isIncome = transaction.categoryType == CategoryType.Income;
    final Color amountColor = isIncome ? AppColors.success : Theme.of(context).colorScheme.error; // Hata rengini temadan al
    // TODO: categoryIcon string'ini gerçek IconData'ya çevir (bir map veya helper fonksiyon ile)
    final IconData categoryIcon = Icons.category_outlined; // Placeholder

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: CircleAvatar(
        backgroundColor: amountColor.withOpacity(0.1), // Tutarın rengine göre arkaplan
        child: Icon(categoryIcon, size: 20, color: amountColor), // Tutarın rengine göre ikon
      ),
      title: Text(
        transaction.categoryName,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        transaction.accountName, // Hesap adı
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            // Amount işaretini burada tekrar kontrol etmeye gerek yok, modelden geldiği gibi kullan
            currencyFormatter.format(transaction.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w600,
                fontSize: 15 // Biraz daha belirgin
            ),
          ),
          Text(
            DateFormat('dd MMM yy', 'tr_TR').format(transaction.transactionDate), // Tarih formatı (yıl da eklendi)
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () {
        // TODO: İşlem detayına git (Get.toNamed)
        print('İşlem tıklandı: ${transaction.id}');
      },
    );
  }
}
