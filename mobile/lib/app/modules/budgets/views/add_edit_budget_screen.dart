import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/modules/budgets/controllers/add_edit_budget_controller.dart';

/// Bütçe ekleme/düzenleme ekranı.
class AddEditBudgetScreen extends GetView<AddEditBudgetController> {
  const AddEditBudgetScreen({super.key});

  // Para formatlayıcı
  NumberFormat get currencyFormatter =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text(controller.isEditing.value ? 'Bütçe Düzenle' : 'Yeni Bütçe')),
        centerTitle: true,
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Kategori Seçimi
            _buildCategorySelector(context),
            const SizedBox(height: 16),

            // Bütçe Tutarı
            _buildAmountField(context),
            const SizedBox(height: 16),

            // Ay/Yıl Seçimi
            _buildPeriodSelector(context),
            const SizedBox(height: 24),

            // Kaydet Butonu
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  /// Kategori seçici widget'ı
  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategori', // Removed const
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isCategoriesLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.categories.isEmpty) {
            return const Center(child: Text('Kategori bulunamadı'));
          }

          return DropdownButtonFormField<int>(
            value: controller.categoryId.value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: controller.categories.map((category) {
              return DropdownMenuItem<int>(
                value: category.id,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      child: category.iconName != null &&
                              category.iconName!.isNotEmpty
                          ? Icon(
                              IconData(int.parse(category.iconName!),
                                  fontFamily: 'MaterialIcons'),
                              color: Theme.of(context).colorScheme.primary)
                          : Icon(Icons.category_outlined,
                              color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(category.name),
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
            validator: (value) {
              if (value == null) {
                return 'Lütfen bir kategori seçin';
              }
              return null;
            },
          );
        }),
      ],
    );
  }

  /// Bütçe tutarı giriş alanı
  Widget _buildAmountField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bütçe Tutarı', // Removed const
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: controller.amount.value > 0
              ? currencyFormatter.format(controller.amount.value)
              : '',
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.currency_lira),
            hintText: '0.00',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            // Para formatını temizle ve double'a çevir
            final cleanValue = value
                .replaceAll('₺', '')
                .replaceAll('.', '')
                .replaceAll(',', '.')
                .trim();
            if (cleanValue.isNotEmpty) {
              controller.amount.value = double.parse(cleanValue);
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
        Text('Dönem', // Removed const
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            // Ay seçici
            Expanded(
              child: DropdownButtonFormField<int>(
                value: controller.month.value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
              ),
            ),
            const SizedBox(width: 16),
            // Yıl seçici
            Expanded(
              child: DropdownButtonFormField<int>(
                value: controller.year.value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
              ),
            ),
          ],
        ),
      ],
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

  /// Kaydet butonu
  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(controller.isEditing.value ? 'Güncelle' : 'Oluştur'),
        ));
  }
}
