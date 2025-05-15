import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/modules/transactions/controllers/add_edit_transaction_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/services/dialog_service.dart';

/// İşlem ekleme/düzenleme ekranı
class AddEditTransactionScreen extends GetView<AddEditTransactionController> {
  const AddEditTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditing.value ? 'İşlem Düzenle' : 'Yeni İşlem',
              style: Get.theme.textTheme.titleLarge?.copyWith(
                fontWeight:
                    FontWeight.bold, // titleLarge w600, bunu bold yapıyoruz
              ),
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
                _TypeSelectorWidget(controller: controller),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Tutar
                      _AmountInputField(controller: controller),

                      const SizedBox(height: 24),

                      // Hesap Seçimi
                      _buildSectionTitle('Hesap'),
                      _AccountDropdownWidget(controller: controller),

                      const SizedBox(height: 20),

                      // Kategori Seçimi
                      _buildSectionTitle('Kategori'),
                      _CategorySelectorWidget(controller: controller),

                      const SizedBox(height: 20),

                      // Tarih
                      _buildSectionTitle('Tarih'),
                      _DateSelector(controller: controller),

                      const SizedBox(height: 20),

                      // Notlar
                      _buildSectionTitle('Notlar (Opsiyonel)'),
                      _buildNotesField(),

                      const SizedBox(height: 32),

                      // Kaydet Butonu
                      _SaveButton(controller: controller),

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
        style: Get.theme.textTheme.bodyMedium?.copyWith(
          // fontSize: 14, // bodyMedium zaten 14
          fontWeight: FontWeight.w500,
          // color: AppColors.textSecondary, // bodyMedium zaten bu renkte
        ),
      ),
    );
  }

  // _buildTypeSelector metodu _TypeSelectorWidget'a taşındı.

  // _buildAccountDropdown metodu _AccountDropdownWidget'a taşındı.
  // _buildCategorySelector metodu _CategorySelectorWidget'a taşındı.

  // _buildAmountField metodu _AmountInputField'a taşındı.

  // _buildDateSelector metodu _DateSelector'a taşındı.

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

  // _buildSaveButton metodu _SaveButton'a taşındı.

  // _buildEmptyStateCard metodu _EmptyStateCardWidget'a taşındı.

  /// Silme onay dialodu
  void _showDeleteConfirmation(BuildContext context) {
    DialogService.showDeleteConfirmationDialog(
      title: 'İşlemi Sil',
      message: 'Bu işlemi silmek istediğinizden emin misiniz?',
      onConfirm: () {
        controller.deleteTransaction();
      },
    );
  }
}

// --- Ayrılmış Widget Sınıfları ---

/// İşlem türü seçici (gelir/gider)
class _TypeSelectorWidget extends StatelessWidget {
  final AddEditTransactionController controller;

  const _TypeSelectorWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
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
                          style: Get.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? typeColor
                                : AppColors.textSecondary,
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
}

/// Tutar giriş alanı
class _AmountInputField extends StatelessWidget {
  final AddEditTransactionController controller;

  const _AmountInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Color textColor =
          controller.selectedType.value == CategoryType.Income
              ? AppColors.success
              : AppColors.error;

      return Center(
        child: TextFormField(
          controller: controller.amountController,
          textAlign: TextAlign.center,
          style: Get.theme.textTheme.displayLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: '0,00 ₺',
            hintStyle: Get.theme.textTheme.displayLarge?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withOpacity(0.6),
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
}

/// Tarih seçim widget'ı
class _DateSelector extends StatelessWidget {
  final AddEditTransactionController controller;

  const _DateSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
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
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
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
}

/// Kaydet butonu
class _SaveButton extends StatelessWidget {
  final AddEditTransactionController controller;

  const _SaveButton({required this.controller});

  @override
  Widget build(BuildContext context) {
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
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
          ),
        ));
  }
}

/// Hesap dropdown widget'ı
class _AccountDropdownWidget extends StatelessWidget {
  final AddEditTransactionController controller;

  const _AccountDropdownWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.accounts.isEmpty) {
        return _EmptyStateCardWidget(
          // Yeni widget çağrısı
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
}

/// Kategori seçim widget'ı
class _CategorySelectorWidget extends StatelessWidget {
  final AddEditTransactionController controller;

  const _CategorySelectorWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Filtrelenmiş kategoriler
      final filteredCategories = controller.categories
          .where((category) => category.type == controller.selectedType.value)
          .toList();

      if (filteredCategories.isEmpty) {
        return _EmptyStateCardWidget(
          // Yeni widget çağrısı
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
}

/// Boş durum kartı widget'ı
class _EmptyStateCardWidget extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const _EmptyStateCardWidget({
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
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
            style: Get.theme.textTheme.bodyMedium,
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
}
