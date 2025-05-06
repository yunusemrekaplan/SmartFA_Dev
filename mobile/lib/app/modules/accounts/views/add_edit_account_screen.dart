import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/enums/account_type.dart';
import 'package:mobile/app/theme/app_colors.dart';
import '../controllers/add_edit_account_controller.dart';

class AddEditAccountScreen extends GetView<AddEditAccountController> {
  const AddEditAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isEditing = controller.isEditing.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Hesap Düzenle' : 'Yeni Hesap'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hesap türü seçim kartları
                _buildAccountTypeSelector(context),

                const SizedBox(height: 24),

                // Hesap Adı
                TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'Hesap Adı',
                    hintText: 'Örn: Ana Banka Hesabım',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.account_balance),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hesap adı gereklidir';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Başlangıç Bakiyesi
                TextFormField(
                  controller: controller.balanceController,
                  decoration: InputDecoration(
                    labelText: 'Başlangıç Bakiyesi',
                    hintText: '0.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.payments_outlined),
                    prefixText: '₺ ',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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

                const SizedBox(height: 32),

                // Kaydet Butonu
                ElevatedButton.icon(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.saveAccount(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: controller.isSubmitting.value
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(isEditing
                          ? Icons.check_circle_outline
                          : Icons.add_circle_outline),
                  label: Text(
                    isEditing ? 'Güncelle' : 'Hesap Ekle',
                    style: Get.theme.elevatedButtonTheme.style?.textStyle
                        ?.resolve({})?.copyWith(
                      fontWeight: FontWeight.bold,
                      // fontSize: 16, // Zaten ElevatedButton temasında 16
                      // color: Colors.white, // Zaten ElevatedButton temasında textOnPrimary
                    ),
                  ),
                ),

                // Düzenlemede ise hesabı silme seçeneği
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.deleteAccount(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(
                      // Removed const
                      'Hesabı Sil',
                      style: Get.theme.textTheme.titleMedium?.copyWith(
                        // fontSize: 16, // titleMedium zaten 16
                        fontWeight: FontWeight.bold,
                        color: AppColors
                            .error, // OutlinedButton'ın foregroundColor'ı error
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Hesap türü seçim kartlarını oluşturur
  Widget _buildAccountTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // Removed const
          padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
          child: Text(
            'Hesap Türü',
            style: Get.theme.textTheme.titleMedium?.copyWith(
              // fontSize: 16, // titleMedium zaten 16
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Obx(() => Row(
              children: controller.accountTypes.map((type) {
                final isSelected = controller.selectedAccountType.value == type;
                final (String label, IconData icon, Color color) =
                    _getAccountTypeInfo(type);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectAccountType(type),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: isSelected ? color : Colors.grey,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            style: Get.theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? color
                                  : AppColors
                                      .textSecondary, // Colors.grey.shade700 yerine tema rengi
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  /// Hesap türü bilgilerini döndürür
  (String, IconData, Color) _getAccountTypeInfo(AccountType type) {
    switch (type) {
      case AccountType.Cash:
        return ('Nakit', Icons.wallet_outlined, AppColors.success);
      case AccountType.Bank:
        return ('Banka', Icons.account_balance_outlined, AppColors.primary);
      case AccountType.CreditCard:
        return ('Kredi Kartı', Icons.credit_card_outlined, AppColors.secondary);
    }
  }
}
