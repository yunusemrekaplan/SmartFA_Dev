import 'package:flutter/material.dart';

// Uygulama genelinde kullanılacak renk sabitleri
class AppColors {
  // Ana Renkler - Material 3 Stili
  static const Color primary = Color(0xFF4F6BED); // Modern Mavi
  static const Color primaryLight = Color(0xFF7D95FF);
  static const Color primaryDark = Color(0xFF1944BA);

  // İkincil Renkler
  static const Color secondary = Color(0xFFFF9054); // Sıcak Turuncu
  static const Color secondaryLight = Color(0xFFFFB482);
  static const Color secondaryDark = Color(0xFFE86C28);

  // Arkaplan Renkleri
  static const Color background = Color(0xFFF8F9FC); // Çok açık mavi-gri
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F3F8); // Açık mavi-gri

  // Metin Renkleri
  static const Color textPrimary = Color(0xFF1E293B); // Koyu Lacivert
  static const Color textSecondary = Color(0xFF64748B); // Orta Gri-Mavi
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;

  // Durum Renkleri
  static const Color error = Color(0xFFE53935); // Kırmızı
  static const Color success = Color(0xFF4CAF50); // Yeşil
  static const Color warning = Color(0xFFFFA000); // Amber
  static const Color info = Color(0xFF2196F3); // Mavi

  // Ek Nötr Renkler
  static const Color border = Color(0xFFE2E8F0); // Açık Gri
  static const Color divider = Color(0xFFEEF2F6); // Daha açık Gri

  // Özel Renk Geçişleri (Gradient için)
  static const List<Color> primaryGradient = [
    Color(0xFF4F6BED),
    Color(0xFF6A7EFF),
  ];

  // Private constructor to prevent instantiation
  AppColors._();
}
