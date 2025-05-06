import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

/// Kayıt olma ekranındaki kullanım koşulları metni
class AuthTermsText extends StatelessWidget {
  const AuthTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                children: [
                  const TextSpan(
                    text: 'Kayıt olarak, ',
                  ),
                  TextSpan(
                    text: 'Kullanım Koşulları',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const TextSpan(
                    text: ' ve ',
                  ),
                  TextSpan(
                    text: 'Gizlilik Politikası',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const TextSpan(
                    text: 'nı kabul etmiş olursunuz.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
