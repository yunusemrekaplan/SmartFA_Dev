import 'package:flutter/material.dart';

// Uygulama genelinde kullanılacak renk sabitleri
class AppColors {
  // Ana Renkler - Material 3 Stili
  static const Color primary =
      Color(0xFF3563DC); // Daha koyu ve erişilebilir mavi
  static const Color primaryLight = Color(0xFF6989F5);
  static const Color primaryDark = Color(0xFF1945B6);

  // İkincil Renkler
  static const Color secondary =
      Color(0xFFFF7D3C); // Daha koyu turuncu (kontrast için)
  static const Color secondaryLight = Color(0xFFFFAA78);
  static const Color secondaryDark = Color(0xFFE05F20);

  // Arkaplan Renkleri
  static const Color background = Color(0xFFF8F9FC); // Çok açık mavi-gri
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F3F8); // Açık mavi-gri
  static const Color surfaceSecondary =
      Color(0xFFFFFBF8); // Çok açık turuncu tonu

  // Metin Renkleri
  static const Color textPrimary =
      Color(0xFF121C2D); // Daha koyu (kontrast arttırıldı)
  static const Color textSecondary =
      Color(0xFF475569); // Daha koyu gri (kontrast arttırıldı)
  static const Color textTertiary = Color(0xFF64748B); // İlave metin tonu
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;

  // Vurgu Renkleri (Finansal)
  static const Color income = Color(0xFF2E7D32); // Gelir için koyu yeşil
  static const Color expense = Color(0xFFD32F2F); // Gider için koyu kırmızı
  static const Color neutral = Color(0xFF455A64); // Nötr işlemler

  // Durum Renkleri
  static const Color error = Color(0xFFD32F2F); // Daha koyu kırmızı
  static const Color success = Color(0xFF2E7D32); // Daha koyu yeşil
  static const Color warning = Color(0xFFED6C02); // Daha koyu amber
  static const Color info = Color(0xFF0277BD); // Daha koyu mavi

  // Ek Nötr Renkler
  static const Color border = Color(0xFFE2E8F0); // Açık Gri
  static const Color divider = Color(0xFFEEF2F6); // Daha açık Gri
  static const Color disabled = Color(0xFFCBD5E1); // Devre dışı öğeler için
  static const Color card = Color(0xFFFFFFFF); // Kart arkaplanı
  static const Color cardHover = Color(0xFFF8FAFF); // Kart hover durumu

  // Özel Renk Geçişleri (Gradient için)
  static const List<Color> primaryGradient = [
    Color(0xFF3563DC),
    Color(0xFF5E7EF4),
  ];

  static const List<Color> successGradient = [
    Color(0xFF2E7D32),
    Color(0xFF4CAF50),
  ];

  static const List<Color> dangerGradient = [
    Color(0xFFD32F2F),
    Color(0xFFE57373),
  ];

  // Gölge renkleri
  static Color shadowLight = Colors.black.withOpacity(0.04);
  static Color shadowMedium = Colors.black.withOpacity(0.08);
  static Color shadowDark = Colors.black.withOpacity(0.12);

  // Private constructor to prevent instantiation
  AppColors._();
}
