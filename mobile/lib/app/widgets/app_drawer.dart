import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/settings/settings_screen.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/modules/auth/widgets/loading_logo.dart';

/// Uygulamanın modern ve animasyonlu drawer menüsü
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Drawer(
        elevation: 16,
        backgroundColor: Colors.white,
        child: Stack(
          children: [
            // Arka plan dekorasyon elemanı
            Positioned(
              top: -120,
              left: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
              ),
            ),

            // Ana içerik
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 12),

                        // Ana menü öğeleri
                        _buildDrawerHeader(context, 'UYGULAMA'),
                        _buildMenuTile(
                          context: context,
                          icon: Icons.settings_rounded,
                          title: 'Ayarlar',
                          onTap: () {
                            Get.to(
                              () => const SettingsScreen(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 250),
                            );
                            Navigator.pop(context);
                          },
                        ),

                        _buildDivider(),

                        // Destek menü öğeleri
                        _buildDrawerHeader(context, 'DESTEK'),
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

                        _buildDivider(),

                        // Hesap menü öğeleri
                        _buildDrawerHeader(context, 'HESAP'),
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
                          isDestructive: true,
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
          ],
        ),
      ),
    );
  }

  /// Özel ayraç widget'ı
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.divider.withOpacity(0.1),
            AppColors.divider,
            AppColors.divider.withOpacity(0.1),
          ]),
        ),
      ),
    );
  }

  /// Drawer üst kısmını (header) oluşturur
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGradient[0],
            AppColors.primaryGradient[1],
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'app_logo',
                child: LogoWithAnimation(
                  size: 58,
                  animate: false,
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'SmartFA',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
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
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
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
    bool isDestructive = false,
  }) {
    final Color iconColor = isDestructive ? AppColors.error : AppColors.primary;
    final Color textColor =
        isDestructive ? AppColors.error : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Drawer alt kısmını (footer) oluşturur
  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Sürüm 1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '© 2023 SmartFA',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Uygulanmamış özellikler için bildirim gösterir
  void _showNotImplementedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Bu özellik henüz uygulanmadı'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.info,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 24,
        );
      },
    );
  }
}
