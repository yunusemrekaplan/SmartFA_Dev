import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/budgets/Widgets/budget_form.dart';
import 'package:mobile/app/modules/budgets/controllers/add_edit_budget_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Bütçe ekleme/düzenleme ekranı.
class AddEditBudgetScreen extends GetView<AddEditBudgetController> {
  const AddEditBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditing.value ? 'Bütçe Düzenle' : 'Yeni Bütçe',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            )),
        centerTitle: true,
        actions: [
          // Silme butonu (Sadece düzenleme modunda göster)
          Obx(() => controller.isEditing.value
              ? IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  tooltip: 'Bütçeyi Sil',
                  onPressed: () {
                    // Silme onayı için dialog göster
                    Get.defaultDialog(
                      title: "Bütçeyi Sil",
                      middleText:
                          "Bu bütçeyi silmek istediğinizden emin misiniz?",
                      textConfirm: "Sil",
                      textCancel: "İptal",
                      confirmTextColor: Colors.white,
                      backgroundColor: Colors.white,
                      titleStyle: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      middleTextStyle: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      cancelTextColor: AppColors.textPrimary,
                      buttonColor: AppColors.error,
                      radius: AppTheme.kBorderRadius,
                      onConfirm: () {
                        Get.back(); // Dialogu kapat
                        controller.deleteBudget(controller.budgetId.value!);
                      },
                    );
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: SafeArea(
        child: BudgetForm(
          controller: controller,
          formKey: controller.formKey,
        ).animate().fadeIn(
              duration: const Duration(milliseconds: 300),
            ),
      ),
    );
  }
}
