import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/budgets/controllers/budget_add_edit_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Bütçe düzenleme ekranı Header bileşeni - SRP (Single Responsibility) prensibi uygulandı
class BudgetHeader extends StatelessWidget {
  final BudgetAddEditController controller;

  const BudgetHeader({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // İkon ve başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderText(context),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 200),
        );
  }

  /// Header ikonu
  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Obx(() => Icon(
            controller.isEditing.value
                ? Icons.edit_note_rounded
                : Icons.add_chart_rounded,
            color: AppColors.primary,
            size: 28,
          )),
    );
  }

  /// Header metni (başlık ve alt başlık)
  Widget _buildHeaderText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              controller.isEditing.value
                  ? 'Bütçenizi Güncelleyin'
                  : 'Yeni Bütçe Ekleyin',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            )),
        const SizedBox(height: 4),
        Obx(() => Text(
              controller.isEditing.value
                  ? 'Bütçe tutarınızı güncelleyebilirsiniz'
                  : 'Finansal hedeflerinizi planlayın',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            )),
      ],
    );
  }
}
