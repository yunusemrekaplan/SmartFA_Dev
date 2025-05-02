import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/modules/transactions/add_edit_transaction/add_edit_transaction_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// İşlem ekleme/düzenleme ekranı
class AddEditTransactionScreen extends GetView<AddEditTransactionController> {
  const AddEditTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditing.value ? 'İşlem Düzenle' : 'Yeni İşlem',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            )),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (controller.isEditing.value)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              tooltip: 'İşlemi Sil',
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İşlem Türü Seçimi (Gelir/Gider)
                _buildTypeSelector(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Tutar
                      _buildAmountField(),

                      const SizedBox(height: 24),

                      // Hesap Seçimi
                      _buildSectionTitle('Hesap'),
                      _buildAccountDropdown(),

                      const SizedBox(height: 20),

                      // Kategori Seçimi
                      _buildSectionTitle('Kategori'),
                      _buildCategorySelector(),

                      const SizedBox(height: 20),

                      // Tarih
                      _buildSectionTitle('Tarih'),
                      _buildDateSelector(context),

                      const SizedBox(height: 20),

                      // Notlar
                      _buildSectionTitle('Notlar (Opsiyonel)'),
                      _buildNotesField(),

                      const SizedBox(height: 32),

                      // Kaydet Butonu
                      _buildSaveButton(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Bölüm başlığı oluşturur
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// İşlem türü seçici (gelir/gider)
  Widget _buildTypeSelector() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
          ),
          child: Row(
            children: CategoryType.values.map((type) {
              final bool isSelected = controller.selectedType.value == type;
              final Color typeColor = type == CategoryType.Income
                  ? AppColors.success
                  : AppColors.error;

              return Expanded(
                child: InkWell(
                  onTap: () => controller.selectType(type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? typeColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type == CategoryType.Income
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: isSelected ? typeColor : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type == CategoryType.Income ? 'Gelir' : 'Gider',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? typeColor : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }

  /// Hesap dropdown'ı
  Widget _buildAccountDropdown() {
    return Obx(() {
      if (controller.accounts.isEmpty) {
        return _buildEmptyStateCard(
          message: 'İşlem ekleyebilmek için önce bir hesap eklemelisiniz.',
          buttonText: 'Hesap Ekle',
          onButtonPressed: () => Get.toNamed('/accounts/add'),
        );
      }

      return DropdownButtonFormField<AccountModel>(
        value: controller.selectedAccount.value,
        decoration: InputDecoration(
          hintText: 'Hesap Seçin',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        isExpanded: true,
        items: controller.accounts
            .map((account) => DropdownMenuItem(
                  value: account,
                  child: Text(account.name),
                ))
            .toList(),
        onChanged: (value) => controller.selectAccount(value!),
        validator: (value) => value == null ? 'Lütfen bir hesap seçin' : null,
      );
    });
  }

  /// Kategori seçim widget'ı
  Widget _buildCategorySelector() {
    return Obx(() {
      // Filtrelenmiş kategoriler
      final filteredCategories = controller.categories
          .where((category) => category.type == controller.selectedType.value)
          .toList();

      if (filteredCategories.isEmpty) {
        return _buildEmptyStateCard(
          message: 'Seçilen işlem türü için kategori bulunamadı.',
          buttonText: 'Kategori Ekle',
          onButtonPressed: () => Get.toNamed('/categories/add'),
        );
      }

      return DropdownButtonFormField<CategoryModel>(
        value: controller.selectedCategory.value,
        decoration: InputDecoration(
          hintText: 'Kategori Seçin',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        isExpanded: true,
        items: filteredCategories.map((category) {
          // Kategori ikonu (varsa)
          IconData? categoryIcon;
          if (category.iconName != null && category.iconName!.isNotEmpty) {
            try {
              categoryIcon = IconData(
                int.parse(category.iconName!),
                fontFamily: 'MaterialIcons',
              );
            } catch (_) {}
          }

          return DropdownMenuItem<CategoryModel>(
            value: category,
            child: Row(
              children: [
                if (categoryIcon != null) ...[
                  Icon(
                    categoryIcon,
                    size: 16,
                    color: category.type == CategoryType.Income
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(category.name),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) => controller.selectCategory(value!),
        validator: (value) =>
            value == null ? 'Lütfen bir kategori seçin' : null,
      );
    });
  }

  /// Tutar giriş alanı
  Widget _buildAmountField() {
    return Obx(() {
      final Color textColor =
          controller.selectedType.value == CategoryType.Income
              ? AppColors.success
              : AppColors.error;

      return Center(
        child: TextFormField(
          controller: controller.amountController,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: '0,00 ₺',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen bir tutar girin';
            }
            if (double.tryParse(value.replaceAll(',', '.')) == null) {
              return 'Geçerli bir tutar girin';
            }
            return null;
          },
        ),
      );
    });
  }

  /// Tarih seçim widget'ı
  Widget _buildDateSelector(BuildContext context) {
    return Obx(() => InkWell(
          onTap: () => controller.selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMMM yyyy', 'tr_TR')
                      .format(controller.selectedDate.value),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ));
  }

  /// Notlar giriş alanı
  Widget _buildNotesField() {
    return TextFormField(
      controller: controller.notesController,
      decoration: InputDecoration(
        hintText: 'İşlemle ilgili notlar...',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      maxLines: 3,
    );
  }

  /// Kaydet butonu
  Widget _buildSaveButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : () => controller.saveTransaction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            ),
            child: controller.isSubmitting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    controller.isEditing.value ? 'Kaydet' : 'İşlem Ekle',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ));
  }

  /// Boş durum kartı
  Widget _buildEmptyStateCard({
    required String message,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  /// Silme onay dialodu
  void _showDeleteConfirmation(BuildContext context) {
    Get.defaultDialog(
      title: 'İşlemi Sil',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Bu işlemi silmek istediğinizden emin misiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      textConfirm: 'Sil',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      textCancel: 'İptal',
      cancelTextColor: AppColors.textPrimary,
      onConfirm: () {
        Get.back(); // Dialogu kapat
        controller.deleteTransaction();
      },
      radius: 8,
    );
  }
}
