import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/app/modules/budgets/controllers/budget_add_edit_controller.dart';

import 'amount_field.dart';
import 'category_selector.dart';
import 'period_selector.dart';
import 'section_title.dart';
import 'submit_button.dart';

/// Bütçe formu widget'ı - SOLID prensiplerine göre yeniden yapılandırıldı
/// SRP, OCP ve DIP prensiplerine uygun
class BudgetForm extends StatelessWidget {
  final BudgetAddEditController controller;
  final GlobalKey<FormState> formKey;

  const BudgetForm({super.key, required this.controller, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Kategori Seçimi
          const SectionTitle(
            title: 'Kategori',
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 16),
          CategorySelector(controller: controller),
          const SizedBox(height: 32),

          // Bütçe Tutarı
          const SectionTitle(
            title: 'Bütçe Tutarı',
            icon: Icons.account_balance_wallet_outlined,
            animationDelay: Duration(milliseconds: 300),
          ),
          const SizedBox(height: 16),
          AmountField(controller: controller),
          const SizedBox(height: 32),

          // Ay/Yıl Seçimi
          const SectionTitle(
            title: 'Dönem',
            icon: Icons.calendar_today_outlined,
            animationDelay: Duration(milliseconds: 400),
          ),
          const SizedBox(height: 16),
          PeriodSelector(controller: controller),
          const SizedBox(height: 40),

          // Kaydet Butonu
          SubmitButton(controller: controller),
        ],
      ).animate().fadeIn(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutQuad,
          ),
    );
  }
}
