import 'package:flutter/material.dart';

/// Snackbar içinde gösterilecek buton
class SnackBarButton {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  SnackBarButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });
}
