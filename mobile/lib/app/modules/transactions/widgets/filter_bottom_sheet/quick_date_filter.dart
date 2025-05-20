import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';

class QuickDateFilter extends StatelessWidget {
  final TransactionsController controller;

  const QuickDateFilter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildQuickDateButton('Bugün', () => _applyQuickDate('today')),
          _buildQuickDateButton('Dün', () => _applyQuickDate('yesterday')),
          _buildQuickDateButton('Bu Hafta', () => _applyQuickDate('thisWeek')),
          _buildQuickDateButton('Bu Ay', () => _applyQuickDate('thisMonth')),
          _buildQuickDateButton('Geçen Ay', () => _applyQuickDate('lastMonth')),
          _buildQuickDateButton(
              'Son 3 Ay', () => _applyQuickDate('last3Months')),
        ],
      ),
    );
  }

  /// Quick date filtresi uygular ve bottom sheet'i kapatır
  void _applyQuickDate(String period) {
    controller.applyQuickDateFilter(period);
    Get.back();
  }

  /// Hızlı tarih filtre butonu
  Widget _buildQuickDateButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          color: AppColors.primary.withOpacity(0.05),
        ),
        child: Text(
          title,
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
