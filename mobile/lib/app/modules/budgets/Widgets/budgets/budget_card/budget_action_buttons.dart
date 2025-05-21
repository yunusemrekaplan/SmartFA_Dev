import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/core/services/dialog/i_dialog_service.dart';
import 'package:mobile/app/domain/models/response/budget_response_model.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';

/// Bütçe kartında yer alan işlem butonlarını (düzenleme ve silme) yönetir.
class BudgetActionButtons extends StatelessWidget {
  final BudgetModel budget;
  final BudgetsController controller;

  const BudgetActionButtons({
    super.key,
    required this.budget,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        if (result == 'edit') {
          controller.goToEditBudget(budget);
        } else if (result == 'delete') {
          controller.deleteBudget(budget.id);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Düzenle'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            title: Text(
              'Sil',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
