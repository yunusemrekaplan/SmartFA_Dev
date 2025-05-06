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
      elevation: 8,
      notchMargin: 8.0,
      shape: const CircularNotchedRectangle(),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 0),
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              context: context,
              icon: Icons.dashboard_rounded,
              index: 0,
              label: 'Özet',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.account_balance_wallet_rounded,
              index: 1,
              label: 'Hesaplar',
            ),
            const SizedBox(width: 56), // FAB için daha geniş boşluk
            _buildNavItem(
              context: context,
              icon: Icons.sync_alt_rounded,
              index: 2,
              label: 'İşlemler',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.pie_chart_rounded,
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
    required int index,
    required String label,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;

      return InkWell(
        customBorder: const CircleBorder(),
        onTap: () => controller.changeTabIndex(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: (isSelected
                        ? Theme.of(context)
                            .bottomNavigationBarTheme
                            .selectedLabelStyle
                        : Theme.of(context)
                            .bottomNavigationBarTheme
                            .unselectedLabelStyle)
                    ?.copyWith(
                        fontSize:
                            12), // Temadan alıp font boyutunu 12 yapıyoruz (tema 13)
              ),
            ],
          ),
        ),
      );
    });
  }
}
