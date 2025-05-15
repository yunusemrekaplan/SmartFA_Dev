import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/budgets/controllers/budget_add_edit_controller.dart';
import 'package:mobile/app/modules/budgets/widgets/budget_add_edit/budget_edit_app_bar.dart';
import 'package:mobile/app/modules/budgets/widgets/budget_add_edit/budget_form/budget_form.dart';
import 'package:mobile/app/modules/budgets/widgets/budget_add_edit/budget_header.dart';
import 'package:mobile/app/services/dialog_service.dart';
import 'package:mobile/app/theme/app_colors.dart';

class BudgetAddEditScreen extends GetView<BudgetAddEditController> {
  const BudgetAddEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BudgetEditAppBar(
        controller: controller,
        onDeletePressed: () => _showDeleteConfirmation(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            BudgetHeader(controller: controller),

            // Form içeriği
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.only(top: 28, left: 20, right: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: BudgetForm(
                  controller: controller,
                  formKey: controller.formKey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Silme onayı dialog'unu göster
  void _showDeleteConfirmation(BuildContext context) {
    DialogService.showDeleteConfirmationDialog(
      title: "Bütçeyi Sil",
      message:
          "Bu bütçeyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.",
      onConfirm: () async {
        await controller.deleteBudget(controller.budgetId.value!);
      },
    );
  }
}
