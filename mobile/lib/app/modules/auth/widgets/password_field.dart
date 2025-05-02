import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/auth/widgets/auth_form_field.dart';

/// Görünürlük toggle özelliği olan şifre alanı
class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final RxBool isPasswordVisible;
  final Function toggleVisibility;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const PasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.isPasswordVisible,
    required this.toggleVisibility,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => AuthFormField(
          controller: controller,
          labelText: labelText,
          hintText: hintText,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () => toggleVisibility(),
          ),
          obscureText: !isPasswordVisible.value,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
        ));
  }
}
