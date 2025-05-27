import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/request/debt_request_models.dart';
import 'package:mobile/app/domain/models/response/debt_response_model.dart';
import 'package:mobile/app/modules/debts/controllers/debt_controller.dart';

class DebtFormDialog extends StatefulWidget {
  final DebtModel? debt;

  const DebtFormDialog({Key? key, this.debt}) : super(key: key);

  @override
  State<DebtFormDialog> createState() => _DebtFormDialogState();
}

class _DebtFormDialogState extends State<DebtFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lenderNameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _remainingAmountController = TextEditingController();
  String _selectedCurrency = 'TRY';

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      _nameController.text = widget.debt!.name;
      _lenderNameController.text = widget.debt!.lenderName ?? '';
      _totalAmountController.text = widget.debt!.totalAmount.toString();
      _remainingAmountController.text = widget.debt!.remainingAmount.toString();
      _selectedCurrency = widget.debt!.currency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lenderNameController.dispose();
    _totalAmountController.dispose();
    _remainingAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DebtController>();
    final isEditing = widget.debt != null;

    return AlertDialog(
      title: Text(isEditing ? 'Borç Düzenle' : 'Yeni Borç'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Borç Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen borç adını girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lenderNameController,
                decoration: const InputDecoration(
                    labelText: 'Alacaklı Adı (Opsiyonel)'),
              ),
              if (!isEditing) ...[
                TextFormField(
                  controller: _totalAmountController,
                  decoration: const InputDecoration(labelText: 'Toplam Tutar'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen toplam tutarı girin';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _remainingAmountController,
                  decoration: const InputDecoration(labelText: 'Kalan Tutar'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen kalan tutarı girin';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  decoration: const InputDecoration(labelText: 'Para Birimi'),
                  items: const [
                    DropdownMenuItem(value: 'TRY', child: Text('TRY')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (isEditing) {
                final success = await controller.updateDebt(
                  widget.debt!.id,
                  UpdateDebtRequestModel(
                    name: _nameController.text,
                    lenderName: _lenderNameController.text.isEmpty
                        ? null
                        : _lenderNameController.text,
                  ),
                );
                if (success) {
                  Navigator.pop(context);
                }
              } else {
                final success = await controller.createDebt(
                  CreateDebtRequestModel(
                    name: _nameController.text,
                    lenderName: _lenderNameController.text.isEmpty
                        ? null
                        : _lenderNameController.text,
                    totalAmount: double.parse(_totalAmountController.text),
                    remainingAmount:
                        double.parse(_remainingAmountController.text),
                    currency: _selectedCurrency,
                  ),
                );
                if (success) {
                  Navigator.pop(context);
                }
              }
            }
          },
          child: Text(isEditing ? 'Güncelle' : 'Ekle'),
        ),
      ],
    );
  }
}
