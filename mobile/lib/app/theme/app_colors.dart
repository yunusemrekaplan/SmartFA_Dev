import 'package:flutter/material.dart';

// Uygulama genelinde kullanılacak renk sabitleri
class AppColors {
  // Ana Renkler (Örnek - Mavi Tonları)
  static const Color primary = Color(0xFF0D47A1); // Koyu Mavi
  static const Color primaryLight = Color(0xFF5472D3);
  static const Color primaryDark = Color(0xFF002171);

  // İkincil Renkler (Accent - Örnek - Turuncu Tonları)
  static const Color secondary = Color(0xFFFF9800); // Turuncu
  static const Color secondaryLight = Color(0xFFFFC947);
  static const Color secondaryDark = Color(0xFFC66900);

  // Arkaplan Renkleri
  static const Color background = Color(0xFFF5F5F5); // Açık Gri
  static const Color surface = Colors.white; // Kartlar, dialoglar vb. için

  // Metin Renkleri
  static const Color textPrimary = Color(0xFF212121); // Koyu Gri / Siyah
  static const Color textSecondary = Color(0xFF757575); // Orta Gri
  static const Color textOnPrimary = Colors.white; // Ana renk üzerindeki metin
  static const Color textOnSecondary = Colors.black; // İkincil renk üzerindeki metin

  // Hata Rengi
  static const Color error = Color(0xFFD32F2F); // Kırmızı

  // Diğer Renkler (İhtiyaca göre)
  static const Color success = Color(0xFF388E3C); // Yeşil
  static const Color warning = Color(0xFFFFA000); // Amber
  static const Color info = Color(0xFF1976D2); // Mavi

  // Private constructor to prevent instantiation
  AppColors._();
}
