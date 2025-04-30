import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/request/transaction_request_models.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/modules/transactions/add_edit_transaction_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

class AddEditTransactionScreen extends GetView<AddEditTransactionController> {
  const AddEditTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing.value ? 'İşlem Düzenle' : 'Yeni İşlem'),
        actions: [
          if (controller.isEditing.value)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => controller.deleteTransaction(),
            ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // İşlem Türü Seçimi
            Obx(() => DropdownButtonFormField<CategoryType>(
                  value: controller.selectedType.value,
                  decoration: const InputDecoration(
                    labelText: 'İşlem Türü',
                    border: OutlineInputBorder(),
                  ),
                  items: CategoryType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type == CategoryType.Income
                                ? 'Gelir'
                                : 'Gider'),
                          ))
                      .toList(),
                  onChanged: (value) => controller.selectType(value!),
                )),
            const SizedBox(height: 16),

            // Hesap Seçimi
            Obx(() => DropdownButtonFormField<AccountModel>(
                  value: controller.selectedAccount.value,
                  decoration: const InputDecoration(
                    labelText: 'Hesap',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.accounts
                      .map((account) => DropdownMenuItem(
                            value: account,
                            child: Text(account.name),
                          ))
                      .toList(),
                  onChanged: (value) => controller.selectAccount(value!),
                )),
            const SizedBox(height: 16),

            // Kategori Seçimi
            Obx(() => DropdownButtonFormField<CategoryModel>(
                  value: controller.selectedCategory.value,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.categories
                      .where((category) =>
                          category.type == controller.selectedType.value)
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          ))
                      .toList(),
                  onChanged: (value) => controller.selectCategory(value!),
                )),
            const SizedBox(height: 16),

            // Tutar
            TextFormField(
              controller: controller.amountController,
              decoration: const InputDecoration(
                labelText: 'Tutar',
                border: OutlineInputBorder(),
                prefixText: '₺ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir tutar girin';
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir tutar girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tarih
            Obx(() => InkWell(
                  onTap: () => controller.selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tarih',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormat('dd.MM.yyyy')
                          .format(controller.selectedDate.value),
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // Notlar
            TextFormField(
              controller: controller.notesController,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Kaydet Butonu
            ElevatedButton(
              onPressed: () => controller.saveTransaction(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Kaydet',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
