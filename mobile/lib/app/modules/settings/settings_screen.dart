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
            leading: const Icon(
                Icons.account_balance_outlined), // Veya fa-receipt ikonu
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
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Çıkış Yap'),
              subtitle: const Text('Hesabınızdan çıkış yapın'),
              onTap: () => _showLogoutConfirmationDialog(context),
            ),
          ),
          const Divider(height: 1, indent: 16),

          // --- Uygulama Bilgileri ---
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Uygulama Sürümü: 1.0.0 (MVP)', // TODO: Paket bilgisinden al
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
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
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 20.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary, // Ana renk
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1),
      ),
    );
  }

  /// Çıkış yapmadan önce onay diyaloğu gösterir
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content:
            const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Diyaloğu kapat
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Önce diyaloğu kapat
              controller.logout(); // Sonra çıkış yap
            },
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
