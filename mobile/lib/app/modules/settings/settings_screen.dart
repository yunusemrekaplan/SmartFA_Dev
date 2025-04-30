import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'settings_controller.dart';

/// Ayarlar ekranı.
class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // --- Hesap Ayarları Bölümü ---
          // _buildSectionTitle(context, 'Hesap'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.goToProfile,
          ),
          const Divider(height: 1, indent: 16),

          // --- Uygulama Ayarları Bölümü ---
          _buildSectionTitle(context, 'Uygulama'),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Kategorileri Yönet'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.goToCategories,
          ),
          const Divider(height: 1, indent: 16),
          ListTile(
            leading: const Icon(Icons.account_balance_outlined), // Veya fa-receipt ikonu
            title: const Text('Borç Yönetimi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.goToDebts, // Borçlar ekranına yönlendir
          ),
          const Divider(height: 1, indent: 16),
          // TODO: Diğer ayarlar eklenebilir (Para Birimi, Tema, Bildirimler vb.)
          // ListTile(
          //   leading: const Icon(Icons.color_lens_outlined),
          //   title: const Text('Görünüm'),
          //   trailing: const Icon(Icons.chevron_right),
          //   onTap: () { /* Tema seçimi vb. */},
          // ),
          // const Divider(height: 1, indent: 16),

          // --- Çıkış Yap Bölümü ---
          const SizedBox(height: 30), // Biraz boşluk
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('Çıkış Yap', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () {
              // Çıkış yapmadan önce onay al
              Get.defaultDialog(
                title: "Çıkış Yap",
                middleText: "Oturumu kapatmak istediğinizden emin misiniz?",
                textConfirm: "Çıkış Yap",
                textCancel: "İptal",
                confirmTextColor: Colors.white,
                buttonColor: Theme.of(context).colorScheme.error,
                // Onay butonu rengi
                cancelTextColor: Theme.of(context).textTheme.bodyLarge?.color,
                onConfirm: () {
                  Get.back(); // Dialogu kapat
                  controller.logout(); // Controller'daki logout metodunu çağır
                },
                onCancel: () => Get.back(), // Sadece dialogu kapat
              );
            },
            // Yüklenme durumunu göster (opsiyonel)
            trailing: Obx(() => controller.isLoading.value
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const SizedBox.shrink() // Yüklenmiyorsa boşluk
                ),
          ),
          const Divider(height: 1, indent: 16),

          // --- Uygulama Bilgileri ---
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Uygulama Sürümü: 1.0.0 (MVP)', // TODO: Paket bilgisinden al
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Ayarlar bölüm başlığını oluşturan yardımcı widget.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary, // Ana renk
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1),
      ),
    );
  }
}
