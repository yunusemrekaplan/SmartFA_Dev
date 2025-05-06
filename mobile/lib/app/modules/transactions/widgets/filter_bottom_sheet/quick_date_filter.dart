import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';

class QuickDateFilter extends StatelessWidget {
  final TransactionsController controller;

  const QuickDateFilter({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildQuickDateButton(
              'Bugün', () => controller.setQuickDateFilter('today')),
          _buildQuickDateButton(
              'Dün', () => controller.setQuickDateFilter('yesterday')),
          _buildQuickDateButton(
              'Bu Hafta', () => controller.setQuickDateFilter('thisWeek')),
          _buildQuickDateButton(
              'Bu Ay', () => controller.setQuickDateFilter('thisMonth')),
          _buildQuickDateButton(
              'Geçen Ay', () => controller.setQuickDateFilter('lastMonth')),
          _buildQuickDateButton(
              'Son 3 Ay', () => controller.setQuickDateFilter('last3Months')),
        ],
      ),
    );
  }

  /// Hızlı tarih filtre butonu
  Widget _buildQuickDateButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        onTap();
        Get.back();
      },
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
