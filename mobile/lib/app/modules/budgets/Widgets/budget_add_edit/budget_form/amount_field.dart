import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/modules/budgets/controllers/budget_add_edit_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

/// Bütçe tutarı giriş alanı bileşeni - SRP (Single Responsibility) prensibi uygulandı
class AmountField extends StatelessWidget {
  final BudgetAddEditController controller;

  const AmountField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAmountInput(context),
      ],
    )
        .animate()
        .fadeIn(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  /// Tutar giriş alanı
  Widget _buildAmountInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextFormField(
        initialValue: _formatInitialAmount(),
        decoration: _buildInputDecoration(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        onChanged: _onAmountChanged,
        validator: _validateAmount,
      ),
    );
  }

  /// Başlangıç değerini formatla
  String _formatInitialAmount() {
    return controller.amount.value > 0
        ? controller.amount.value.toStringAsFixed(2).replaceAll('.', ',')
        : '';
  }

  /// Input dekorasyonunu oluştur
  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: '0,00',
      fillColor: Colors.transparent,
      filled: true,
      prefixIcon: _buildCurrencyPrefix(),
      border: _buildInputBorder(),
      enabledBorder: _buildInputBorder(),
      focusedBorder: _buildInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// Para birimi prefix'i
  Widget _buildCurrencyPrefix() {
    return Padding(
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
    );
  }

  /// Input border'ını oluştur
  OutlineInputBorder _buildInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
      borderSide: BorderSide.none,
    );
  }

  /// Tutar değiştiğinde çağrılır
  void _onAmountChanged(String value) {
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
  }

  /// Tutar doğrulama
  String? _validateAmount(String? value) {
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
  }
}
