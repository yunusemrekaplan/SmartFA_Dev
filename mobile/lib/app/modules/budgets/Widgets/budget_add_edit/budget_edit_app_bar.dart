import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/budgets/controllers/budget_add_edit_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Bütçe düzenleme ekranı AppBar bileşeni - SRP (Single Responsibility) prensibi uygulandı
class BudgetEditAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BudgetAddEditController controller;
  final VoidCallback onDeletePressed;

  const BudgetEditAppBar({
    Key? key,
    required this.controller,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: _buildBackButton(),
      title: _buildTitle(context),
      actions: [
        // Silme butonu (Sadece düzenleme modunda göster)
        _buildDeleteButton(),
      ],
    );
  }

  /// Geri dönüş butonu
  Widget _buildBackButton() {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.textPrimary,
          size: 16,
        ),
      ),
      onPressed: () => Get.back(),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 300),
        );
  }

  /// Başlık metni
  Widget _buildTitle(BuildContext context) {
    return Obx(() => Text(
              controller.isEditing.value ? 'Bütçe Düzenle' : 'Yeni Bütçe',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            )).animate().fadeIn(
          duration: const Duration(milliseconds: 500),
        );
  }

  /// Silme butonu (sadece düzenleme modunda görünür)
  Widget _buildDeleteButton() {
    return Obx(() => controller.isEditing.value
        ? IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            tooltip: 'Bütçeyi Sil',
            onPressed: onDeletePressed,
          ).animate().fadeIn(
              duration: const Duration(milliseconds: 300),
            )
        : const SizedBox.shrink());
  }
}
