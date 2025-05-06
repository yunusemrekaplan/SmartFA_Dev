import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

class FilterOption extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final Widget subtitle;
  final VoidCallback onTap;

  const FilterOption({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          leadingIcon,
          color: AppColors.primary,
        ),
      ),
      title: Text(title),
      subtitle: subtitle,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}