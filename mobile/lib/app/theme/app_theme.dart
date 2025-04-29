import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

class AppTheme {
  // Açık Tema Ayarları
  static ThemeData get lightTheme {
    return ThemeData(
        useMaterial3: true, // Material 3 kullan
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          primaryContainer: AppColors.primaryLight, // Vurgu için biraz daha açık ton
          secondary: AppColors.secondary,
          onSecondary: AppColors.textOnSecondary,
          secondaryContainer: AppColors.secondaryLight,
          error: AppColors.error,
          onError: Colors.white,
          background: AppColors.background,
          onBackground: AppColors.textPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),

        // Font Ailesi (Opsiyonel - Google Fonts vb. eklenebilir)
        // fontFamily: 'YourCustomFont', // pubspec.yaml'a eklenmeli

        // AppBar Teması
        appBarTheme: const AppBarTheme(
          color: AppColors.primary, // AppBar arkaplanı
          foregroundColor: AppColors.textOnPrimary, // AppBar ikon ve metin rengi
          elevation: 1.0,
          iconTheme: IconThemeData(color: AppColors.textOnPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Buton Temaları
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, // Buton arkaplanı
            foregroundColor: AppColors.textOnPrimary, // Buton metin rengi
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary, // Metin buton rengi
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary, // Dış çizgili buton metin/ikon rengi
            side: const BorderSide(color: AppColors.primary), // Çizgi rengi
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),

        // Input Alanı Teması
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // Input arkaplanı
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),

        // Kart Teması
        cardTheme: CardTheme(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: AppColors.surface,
        ),

        // Text Temaları (İhtiyaca göre daha fazla stil eklenebilir)
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          bodyLarge: TextStyle(fontSize: 16.0, color: AppColors.textPrimary),
          bodyMedium: TextStyle(fontSize: 14.0, color: AppColors.textSecondary),
          labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: AppColors.textOnPrimary), // Butonlar için
        ),

        // Diğer tema ayarları...
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade600,
          // backgroundColor: AppColors.surface, // İsteğe bağlı arkaplan
          type: BottomNavigationBarType.fixed, // Veya shifting
        )
    );
  }

  // Private constructor to prevent instantiation
  AppTheme._();
}
