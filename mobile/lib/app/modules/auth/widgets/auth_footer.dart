import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Login/Register ekranlarının alt kısmında yer alan alternatif aksiyon bağlantısı
class AuthFooter extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback onActionPressed;

  const AuthFooter({
    super.key,
    required this.question,
    required this.actionText,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          // Removed const
          question,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: onActionPressed,
          child: Text(actionText),
        ),
      ],
    );
  }
}
