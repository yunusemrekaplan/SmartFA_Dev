import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Para miktarını görüntülemek için özelleştirilmiş widget.
/// Farklı para birimleri ve formatlama seçenekleri destekler.
class CurrencyText extends StatelessWidget {
  /// Gösterilecek tutar miktarı
  final double amount;

  /// Para birimi kodu (TRY, USD, EUR vs.)
  final String currency;

  /// Metin stillendirmesi
  final TextStyle? style;

  /// Negatif değerler için kırmızı renk kullanılsın mı?
  final bool colorizeNegative;

  /// Metnin hizalaması
  final TextAlign textAlign;

  /// Eksi işareti yerine parantez içinde gösterme
  final bool useParenthesesForNegative;

  /// Ondalık basamak sayısı, null ise para birimine göre belirlenir.
  final int? decimalDigits;

  const CurrencyText({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
    this.colorizeNegative = true,
    this.textAlign = TextAlign.start,
    this.useParenthesesForNegative = false,
    this.decimalDigits,
  });

  @override
  Widget build(BuildContext context) {
    // Para birimi formatını oluştur
    final formatter = NumberFormat.currency(
      locale: 'tr_TR', // Türkiye için
      symbol: _getCurrencySymbol(currency),
      decimalDigits: decimalDigits ?? _getDefaultDecimalDigits(currency),
    );

    final isNegative = amount < 0;
    final absAmount = amount.abs();
    String formattedValue;

    if (useParenthesesForNegative && isNegative) {
      formattedValue = '(${formatter.format(absAmount)})';
    } else {
      formattedValue = formatter.format(isNegative ? -absAmount : absAmount);
    }

    return Text(
      formattedValue,
      style: _getTextStyle(context, style, isNegative),
      textAlign: textAlign,
    );
  }

  /// Negatif/pozitif değerlere göre metin stilini belirler
  TextStyle? _getTextStyle(
      BuildContext context, TextStyle? baseStyle, bool isNegative) {
    final defaultStyle =
        Theme.of(context).textTheme.bodyMedium; // Varsayılan tema stili

    if (!colorizeNegative || !isNegative) {
      // Negatif değilse veya renklendirme kapalıysa, baseStyle veya varsayılanı döndür
      return baseStyle ?? defaultStyle;
    }

    // Negatif ve renklendirme açıksa
    final negativeColor = Theme.of(context).colorScheme.error;
    final styleToUse =
        baseStyle ?? defaultStyle; // Kullanılacak stil (base veya varsayılan)

    // Negatif rengi uygula
    return styleToUse?.copyWith(color: negativeColor);
  }

  /// Para birimi için sembol döndürür
  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'TRY':
        return '₺';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  /// Para birimine göre varsayılan ondalık hane sayısını belirler
  int _getDefaultDecimalDigits(String currency) {
    switch (currency.toUpperCase()) {
      case 'JPY':
        return 0; // Japon Yeni genelde ondalık kullanmaz
      default:
        return 2;
    }
  }
}
