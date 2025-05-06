import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/theme/app_colors.dart';

class TypeFilterButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const TypeFilterButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {

    final buttonColor = color ?? AppColors.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? buttonColor.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? buttonColor : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? buttonColor : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: isSelected ? buttonColor : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}