import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/models/enums/account_type.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/add_edit_account_controller.dart';

class AddEditAccountScreen extends GetView<AddEditAccountController> {
  const AddEditAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isEditing = controller.isEditing.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Hesap Düzenle' : 'Yeni Hesap',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Hata durumu kontrol ediliyor
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bir Hata Oluştu',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    controller.errorMessage.value = '';
                    controller.onInit();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yeniden Dene'),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms);
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              )
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Başlığı
                  Text(
                    isEditing
                        ? 'Hesap Bilgilerini Düzenle'
                        : 'Yeni Hesap Oluştur',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.2, end: 0),

                  Text(
                    isEditing
                        ? 'Hesap bilgilerini güncelleyebilirsiniz.'
                        : 'Takip etmek istediğiniz yeni bir hesap ekleyin.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideX(begin: 0.2, end: 0),

                  const SizedBox(height: 32),

                  // Hesap türü seçim kartları
                  _buildAccountTypeSelector(context)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 28),

                  // Hesap Adı
                  TextFormField(
                    controller: controller.nameController,
                    decoration: InputDecoration(
                      labelText: 'Hesap Adı',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Örn: Ana Banka Hesabım',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.account_balance,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hesap adı gereklidir';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Başlangıç Bakiyesi
                  Obx(() {
                    final selectedType = controller.selectedAccountType.value;
                    final color = _getAccountTypeInfo(selectedType).$3;

                    return TextFormField(
                      controller: controller.balanceController,
                      decoration: InputDecoration(
                        labelText: 'Başlangıç Bakiyesi',
                        labelStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: color,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                          color: color,
                        ),
                        prefixText: '₺ ',
                        prefixStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bakiye gereklidir';
                        }
                        // Sayısal değer kontrolü
                        if (double.tryParse(value.replaceAll(',', '.')) ==
                            null) {
                          return 'Geçerli bir sayı giriniz';
                        }
                        return null;
                      },
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 40),

                  // Butonlar Bölümü
                  Obx(() {
                    final selectedType = controller.selectedAccountType.value;
                    final color = _getAccountTypeInfo(selectedType).$3;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Kaydet Butonu
                        ElevatedButton.icon(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () => controller.saveAccount(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
                              : Icon(
                                  isEditing
                                      ? Icons.check_circle_outline
                                      : Icons.add_circle_outline,
                                  color: Colors.white,
                                ),
                          label: Text(
                            isEditing ? 'Güncelle' : 'Hesap Ekle',
                            style: Get
                                .theme.elevatedButtonTheme.style?.textStyle
                                ?.resolve({})?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline),
                            label: Text(
                              'Hesabı Sil',
                              style: Get.theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                        ],
                      ],
                    );
                  }),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms);
      }),
    );
  }

  /// Hesap türü seçim kartlarını oluşturur
  Widget _buildAccountTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 14.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Hesap Türü',
                style: Get.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.2)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: isSelected ? color : Colors.grey,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            label,
                            style: Get.theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  isSelected ? color : AppColors.textSecondary,
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
