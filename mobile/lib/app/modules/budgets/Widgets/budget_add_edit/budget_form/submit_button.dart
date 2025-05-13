import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/budgets/controllers/budget_add_edit_controller.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

/// Kaydet/Güncelle butonu bileşeni - SRP (Single Responsibility) prensibi uygulandı
class SubmitButton extends StatelessWidget {
  final BudgetAddEditController controller;

  const SubmitButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
                gradient: _buildButtonGradient(),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      controller.isLoading.value ? null : controller.submitForm,
                  borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
                  child: Center(
                    child: _buildButtonContent(context),
                  ),
                ),
              ),
            ))
        .animate()
        .fadeIn(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 600),
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
        );
  }

  /// Buton gradientini oluştur
  LinearGradient _buildButtonGradient() {
    return LinearGradient(
      colors: controller.isLoading.value
          ? [
              AppColors.primary.withOpacity(0.7),
              AppColors.primaryLight.withOpacity(0.7)
            ]
          : AppColors.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Buton içeriğini oluştur
  Widget _buildButtonContent(BuildContext context) {
    return controller.isLoading.value
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
          );
  }
}
