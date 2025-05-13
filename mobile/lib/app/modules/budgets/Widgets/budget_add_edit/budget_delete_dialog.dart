import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_theme.dart';

/// Silme onayı dialog'u - SRP (Single Responsibility) prensibi uygulandı
class BudgetDeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const BudgetDeleteDialog({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Bütçeyi Sil",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        "Bu bütçeyi silmek istediğinizden emin misiniz?\nBu işlem geri alınamaz.",
        style: TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        // İptal butonu
        _buildCancelButton(),

        // Silme butonu
        _buildDeleteButton(),
      ],
    );
  }

  /// İptal butonu
  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => Get.back(),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: const Text("İptal"),
    );
  }

  /// Silme butonu
  Widget _buildDeleteButton() {
    return FilledButton(
      onPressed: onConfirm,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text("Sil"),
        ],
      ),
    );
  }
}
