import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/debts/controllers/debt_controller.dart';
import 'package:mobile/app/modules/debts/widgets/debt_list_item.dart';
import 'package:mobile/app/modules/debts/widgets/debt_form_dialog.dart';

class DebtView extends GetView<DebtController> {
  const DebtView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borçlarım'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDebtDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadDebts(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        if (controller.debts.isEmpty) {
          return const Center(
            child: Text('Henüz borç kaydınız bulunmamaktadır.'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadDebts(),
          child: ListView.builder(
            itemCount: controller.debts.length,
            itemBuilder: (context, index) {
              final debt = controller.debts[index];
              return DebtListItem(
                debt: debt,
                onEdit: () => _showEditDebtDialog(context, debt),
                onDelete: () => _showDeleteConfirmation(context, debt.id),
              );
            },
          ),
        );
      }),
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DebtFormDialog(),
    );
  }

  void _showEditDebtDialog(BuildContext context, debt) {
    showDialog(
      context: context,
      builder: (context) => DebtFormDialog(debt: debt),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int debtId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borç Silme'),
        content: const Text('Bu borcu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteDebt(debtId);
              Navigator.pop(context);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
