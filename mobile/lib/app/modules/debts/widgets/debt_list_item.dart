import 'package:flutter/material.dart';
import 'package:mobile/app/domain/models/response/debt_response_model.dart';

class DebtListItem extends StatelessWidget {
  final DebtModel debt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DebtListItem({
    Key? key,
    required this.debt,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(debt.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (debt.lenderName != null) Text('Alacaklı: ${debt.lenderName}'),
            Text(
              'Kalan Tutar: ${debt.remainingAmount} ${debt.currency}',
              style: TextStyle(
                color: debt.isPaidOff ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
