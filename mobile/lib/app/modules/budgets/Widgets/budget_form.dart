import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/modules/budgets/controllers/add_edit_budget_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

/// Bütçe formu widget'ı
class BudgetForm extends StatelessWidget {
  final AddEditBudgetController controller;
  final GlobalKey<FormState> formKey;

  const BudgetForm({
    Key? key,
    required this.controller,
    required this.formKey,
  }) : super(key: key);

  // Para formatlayıcı
  NumberFormat get currencyFormatter =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Kategori Seçimi
          _buildCategorySelector(context),
          const SizedBox(height: 24),

          // Bütçe Tutarı
          _buildAmountField(context),
          const SizedBox(height: 24),

          // Ay/Yıl Seçimi
          _buildPeriodSelector(context),
          const SizedBox(height: 32),

          // Kaydet Butonu
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  /// Kategori seçici widget'ı
  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          // Sabit boyutlu bir konteyner kullan
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Obx(() {
            // Yükleme durumu
            if (controller.isCategoriesLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // Boş kategori durumu
            if (controller.categories.isEmpty) {
              return Center(
                child: Text(
                  'Kategori bulunamadı',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              );
            }

            // Dropdown widget'ı
            return DropdownButton<int>(
              value: controller.categoryId.value,
              isExpanded: true,
              hint: Text(
                'Kategori seçin',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              underline: const SizedBox.shrink(), // Alttaki çizgiyi kaldır
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              items: controller.categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: category.iconName != null &&
                                category.iconName!.isNotEmpty
                            ? Icon(
                                IconData(int.parse(category.iconName!),
                                    fontFamily: 'MaterialIcons'),
                                color: AppColors.primary,
                                size: 20,
                              )
                            : Icon(
                                Icons.category_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.name,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final category =
                      controller.categories.firstWhere((c) => c.id == value);
                  controller.selectCategory(value, category.name);
                }
              },
            );
          }),
        ),
        // Form doğrulama mesajı
        Obx(() => controller.categoryId.value == null
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                child: Text(
                  'Lütfen bir kategori seçin',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              )
            : const SizedBox.shrink()),
        // Hata mesajı
        Obx(() => controller.errorMessage.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              )
            : const SizedBox.shrink()),
        const SizedBox(height: 8), // İlave boşluk
      ],
    );
  }

  /// Bütçe tutarı giriş alanı
  Widget _buildAmountField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bütçe Tutarı',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: controller.amount.value > 0
              ? controller.amount.value.toStringAsFixed(2).replaceAll('.', ',')
              : '',
          decoration: InputDecoration(
            hintText: '0,00',
            fillColor: AppColors.surfaceVariant,
            filled: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '₺',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          onChanged: (value) {
            // Para formatını temizle ve double'a çevir
            final cleanValue = value
                .replaceAll('₺', '')
                .replaceAll('.', '')
                .replaceAll(',', '.')
                .trim();
            if (cleanValue.isNotEmpty) {
              final parsedValue = double.tryParse(cleanValue);
              if (parsedValue != null) {
                controller.amount.value = parsedValue;
              }
            } else {
              controller.amount.value = 0.0;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen bir tutar girin';
            }
            final cleanValue = value
                .replaceAll('₺', '')
                .replaceAll('.', '')
                .replaceAll(',', '.')
                .trim();
            if (cleanValue.isEmpty) {
              return 'Lütfen bir tutar girin';
            }
            final amount = double.tryParse(cleanValue);
            if (amount == null || amount <= 0) {
              return 'Lütfen geçerli bir tutar girin';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Ay/Yıl seçici widget'ı
  Widget _buildPeriodSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dönem',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Ay seçici
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Obx(() => DropdownButton<int>(
                      value: controller.month.value,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary),
                      dropdownColor: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.kBorderRadius),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      items: List.generate(12, (index) {
                        final month = index + 1;
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(_getMonthName(month)),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          controller.month.value = value;
                        }
                      },
                    )),
              ),
            ),
            const SizedBox(width: 16),
            // Yıl seçici
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Obx(() => DropdownButton<int>(
                      value: controller.year.value,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary),
                      dropdownColor: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.kBorderRadius),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      items: List.generate(5, (index) {
                        final year = DateTime.now().year + index;
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          controller.year.value = value;
                        }
                      },
                    )),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Kaydet butonu
  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(() => FilledButton(
            onPressed:
                controller.isLoading.value ? null : controller.submitForm,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : Text(
                    controller.isEditing.value ? 'Güncelle' : 'Kaydet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
          )),
    );
  }

  /// Ay adını döndüren yardımcı metot
  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return months[month - 1];
  }
}
