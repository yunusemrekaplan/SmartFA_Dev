import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/modules/settings/settings_screen.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/modules/auth/widgets/loading_logo.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/services/dialog_service.dart';

/// Uygulamanın modern ve animasyonlu drawer menüsü
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Drawer(
        elevation: 0,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(context)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, end: 0, duration: 400.ms),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 8),

                    // Ana menü öğeleri
                    _buildDrawerHeader(context, 'UYGULAMA')
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms),

                    _buildMenuTile(
                      context: context,
                      icon: Icons.dashboard_rounded,
                      title: 'Ana Sayfa',
                      isActive: currentRoute == AppRoutes.HOME,
                      onTap: () {
                        Get.offAllNamed(AppRoutes.HOME);
                      },
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                    _buildMenuTile(
                      context: context,
                      icon: Icons.settings_rounded,
                      title: 'Ayarlar',
                      isActive: false,
                      onTap: () {
                        Get.to(
                          () => const SettingsScreen(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 250),
                        );
                        Navigator.pop(context);
                      },
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                    _buildDivider()
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 400.ms),

                    // Kategori Yönetimi - Vurgulu Bölüm
                    _buildFeatureSection(
                      context: context,
                      title: 'KATEGORİLER',
                      icon: Icons.category_rounded,
                      description: 'Özel kategoriler oluşturun ve yönetin',
                      isActive: currentRoute == AppRoutes.CATEGORIES,
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.CATEGORIES);
                      },
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                    _buildDivider()
                        .animate()
                        .fadeIn(delay: 350.ms, duration: 400.ms),

                    // Destek menü öğeleri
                    _buildDrawerHeader(context, 'DESTEK')
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms),

                    _buildMenuTile(
                      context: context,
                      icon: Icons.help_outline_rounded,
                      title: 'Yardım ve Destek',
                      isActive: false,
                      onTap: () {
                        _showNotImplementedMessage(context);
                        Navigator.pop(context);
                      },
                    ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

                    _buildMenuTile(
                      context: context,
                      icon: Icons.info_outline_rounded,
                      title: 'Hakkında',
                      isActive: false,
                      onTap: () {
                        _showNotImplementedMessage(context);
                        Navigator.pop(context);
                      },
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                    _buildDivider()
                        .animate()
                        .fadeIn(delay: 550.ms, duration: 400.ms),

                    // Hesap menü öğeleri
                    _buildDrawerHeader(context, 'HESAP')
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms),

                    _buildMenuTile(
                      context: context,
                      icon: Icons.person_outline_rounded,
                      title: 'Profil',
                      isActive: false,
                      onTap: () {
                        _showNotImplementedMessage(context);
                        Navigator.pop(context);
                      },
                    ).animate().fadeIn(delay: 650.ms, duration: 400.ms),

                    _buildMenuTile(
                      context: context,
                      icon: Icons.logout_rounded,
                      title: 'Çıkış Yap',
                      isDestructive: true,
                      isActive: false,
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                  ],
                ),
              ),
              _buildFooter(context)
                  .animate()
                  .fadeIn(delay: 750.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  /// Özel ayraç widget'ı
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
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
            blurRadius: 16,
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
                  size: 64,
                  animate: false,
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
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
    bool isActive = false,
  }) {
    final Color baseColor = isDestructive ? AppColors.error : AppColors.primary;
    final Color iconColor = isActive ? Colors.white : baseColor;
    final Color textColor = isActive
        ? Colors.white
        : (isDestructive ? AppColors.error : AppColors.textPrimary);
    final Color bgColor = isActive
        ? baseColor
        : (isDestructive
            ? AppColors.error.withOpacity(0.08)
            : Colors.transparent);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: baseColor.withOpacity(0.1),
          highlightColor: baseColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(0.2)
                        : baseColor.withOpacity(0.1),
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
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                        color: textColor,
                      ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Özellik bölümü (vurgulu kart)
  Widget _buildFeatureSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        color: isActive ? AppColors.primary.withOpacity(0.08) : Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
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
      padding: const EdgeInsets.symmetric(vertical: 20),
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
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Çıkış yapmayı onaylama dialogu gösterir
  void _showLogoutDialog(BuildContext context) {
    DialogService.showLogoutConfirmationDialog(
      onConfirm: () {
        Get.find<IAuthRepository>().logout();
        Get.offAllNamed(AppRoutes.LOGIN);
      },
    );
  }
}
