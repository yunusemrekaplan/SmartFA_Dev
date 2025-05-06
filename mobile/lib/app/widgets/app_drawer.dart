import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/settings/settings_screen.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/widgets/loading_logo.dart';

/// Uygulamanın modern drawer menüsü
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),

                  // Ana menü öğeleri
                  _buildDrawerHeader(context, 'Uygulama'),
                  _buildMenuTile(
                    context: context,
                    icon: Icons.settings_rounded,
                    title: 'Ayarlar',
                    onTap: () {
                      Get.to(() => const SettingsScreen());
                      Navigator.pop(context);
                    },
                  ),

                  const Divider(),

                  // Destek menü öğeleri
                  _buildDrawerHeader(context, 'Destek'),
                  _buildMenuTile(
                    context: context,
                    icon: Icons.help_outline_rounded,
                    title: 'Yardım ve Destek',
                    onTap: () {
                      _showNotImplementedMessage(context);
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuTile(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: 'Hakkında',
                    onTap: () {
                      _showNotImplementedMessage(context);
                      Navigator.pop(context);
                    },
                  ),

                  const Divider(),

                  // Hesap menü öğeleri
                  _buildDrawerHeader(context, 'Hesap'),
                  _buildMenuTile(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: 'Profil',
                    onTap: () {
                      _showNotImplementedMessage(context);
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuTile(
                    context: context,
                    icon: Icons.logout_rounded,
                    title: 'Çıkış Yap',
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  /// Drawer üst kısmını (header) oluşturur
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LogoWithAnimation(
            size: 60,
            animate: false,
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'SmartFA',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Akıllı Finansal Asistan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }

  /// Drawer bölüm başlığını oluşturur
  Widget _buildDrawerHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              // fontSize: 12, // labelSmall muhtemelen daha küçük, 12'ye ayarlıyoruz
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  /// Menü öğesi oluşturur
  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: 22,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Drawer alt kısmını (footer) oluşturur
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Sürüm 1.0.0',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Uygulanmamış özellikler için bildirim gösterir
  void _showNotImplementedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu özellik henüz uygulanmadı'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Çıkış yapmayı onaylama dialogu gösterir
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text(
              'Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Logout işlemini gerçekleştir
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Drawer'ı da kapat
                _showNotImplementedMessage(context);
              },
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }
}
