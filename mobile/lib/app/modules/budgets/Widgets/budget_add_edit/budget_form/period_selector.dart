import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/budgets/controllers/budget_add_edit_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

/// Dönem (ay/yıl) seçici bileşeni - SRP (Single Responsibility) prensibi uygulandı
class PeriodSelector extends StatelessWidget {
  final BudgetAddEditController controller;

  const PeriodSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Ay seçici
        Expanded(
          child: _buildMonthSelector(context),
        ),
        const SizedBox(width: 16),
        // Yıl seçici
        Expanded(
          child: _buildYearSelector(context),
        ),
      ],
    );
  }

  /// Ay seçici widget'ını oluştur
  Widget _buildMonthSelector(BuildContext context) {
    return Container(
      height: 60,
      decoration: _buildSelectorDecoration(),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: controller.month.value,
              isExpanded: true,
              icon: _buildDropdownIcon(),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              items: _buildMonthItems(context),
              onChanged: (value) {
                if (value != null) {
                  controller.month.value = value;
                }
              },
            ),
          )),
    )
        .animate()
        .fadeIn(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 500),
        )
        .slideX(
          begin: -0.2,
          end: 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  /// Yıl seçici widget'ını oluştur
  Widget _buildYearSelector(BuildContext context) {
    return Container(
      height: 60,
      decoration: _buildSelectorDecoration(),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: controller.year.value,
              isExpanded: true,
              icon: _buildDropdownIcon(),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              items: _buildYearItems(context),
              onChanged: (value) {
                if (value != null) {
                  controller.year.value = value;
                }
              },
            ),
          )),
    )
        .animate()
        .fadeIn(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 500),
        )
        .slideX(
          begin: 0.2,
          end: 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  /// Seçici kutuların dekorasyonunu oluştur (DRY prensibi)
  BoxDecoration _buildSelectorDecoration() {
    return BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
      border: Border.all(color: AppColors.border, width: 1),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowLight,
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ],
    );
  }

  /// Dropdown ikon widget'ını oluştur (DRY prensibi)
  Widget _buildDropdownIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
    );
  }

  /// Ay öğelerini oluştur
  List<DropdownMenuItem<int>> _buildMonthItems(BuildContext context) {
    return List.generate(12, (index) {
      final month = index + 1;
      return DropdownMenuItem<int>(
        value: month,
        child: Text(
          _getMonthName(month),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      );
    });
  }

  /// Yıl öğelerini oluştur
  List<DropdownMenuItem<int>> _buildYearItems(BuildContext context) {
    return List.generate(5, (index) {
      final year = DateTime.now().year + index;
      return DropdownMenuItem<int>(
        value: year,
        child: Text(
          year.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      );
    });
  }

  /// Ay adını döndüren yardımcı metot
  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return months[month - 1];
  }
}
