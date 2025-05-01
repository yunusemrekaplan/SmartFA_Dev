import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/enums/account_type.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/widgets/custom_app_bar.dart';
import 'add_edit_account_controller.dart';

class AddEditAccountScreen extends GetView<AddEditAccountController> {
  const AddEditAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isEditing = controller.isEditing.value;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Hesap Düzenle' : 'Yeni Hesap',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hesap Adı
                TextFormField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Hesap Adı',
                    hintText: 'Örn: Ana Banka Hesabım',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hesap adı gereklidir';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Hesap Türü
                Obx(() => DropdownButtonFormField<AccountType>(
                      value: controller.selectedAccountType.value,
                      decoration: const InputDecoration(
                        labelText: 'Hesap Türü',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: controller.accountTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                    controller.getAccountTypeDisplayName(type)),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          controller.selectAccountType(value!),
                    )),
                const SizedBox(height: 16),

                // Mevcut Bakiye
                TextFormField(
                  controller: controller.balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Başlangıç Bakiyesi',
                    hintText: '0.00',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money),
                    prefixText: '₺ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bakiye gereklidir';
                    }
                    // Sayısal değer kontrolü
                    if (double.tryParse(value.replaceAll(',', '.')) == null) {
                      return 'Geçerli bir sayı giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Kaydet Butonu
                ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.saveAccount(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Güncelle' : 'Hesap Ekle'),
                ),

                // Düzenlemede ise hesabı silme seçeneği
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.deleteAccount(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Hesabı Sil'),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
