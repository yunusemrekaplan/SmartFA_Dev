import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/home/home_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Özelleştirilmiş ve modern Bottom Navigation Bar
class CustomBottomBar extends StatelessWidget {
  final HomeController controller;

  const CustomBottomBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 12,
      notchMargin: 10.0,
      shape: const CircularNotchedRectangle(),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF8F9FC)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              context: context,
              icon: Icons.dashboard_rounded,
              selectedIcon: Icons.dashboard_rounded,
              index: 0,
              label: 'Özet',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.account_balance_wallet_outlined,
              selectedIcon: Icons.account_balance_wallet_rounded,
              index: 1,
              label: 'Hesaplar',
            ),
            const SizedBox(width: 64), // FAB için daha geniş boşluk
            _buildNavItem(
              context: context,
              icon: Icons.sync_alt_outlined,
              selectedIcon: Icons.sync_alt_rounded,
              index: 2,
              label: 'İşlemler',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.pie_chart_outline_rounded,
              selectedIcon: Icons.pie_chart_rounded,
              index: 3,
              label: 'Bütçeler',
            ),
          ],
        ),
      ),
    );
  }

  /// Gezinme öğesi oluşturan yardımcı metot
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required int index,
    required String label,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;

      return InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => controller.changeTabIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary.withOpacity(0.1),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  key: ValueKey<bool>(isSelected),
                  size: 24,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      );
    });
  }
}
