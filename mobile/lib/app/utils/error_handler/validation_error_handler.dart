import 'package:flutter/material.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/validation_exception.dart';
import 'package:mobile/app/services/dialog_service.dart';
import 'package:mobile/app/utils/error_handler/i_error_handler.dart';
import 'package:mobile/app/utils/snackbar_helper.dart';

/// Doğrulama hatalarını işleyen handler
class ValidationErrorHandler implements IErrorHandler {
  @override
  bool canHandle(AppException error) => error is ValidationException;

  @override
  void handle(
    AppException error,
    String message, {
    VoidCallback? onRetry,
    String? customTitle,
  }) {
    if (error is ValidationException) {
      final title = customTitle ?? 'Doğrulama Hatası';

      // Birden fazla alan hatası varsa
      if (error.fieldErrors != null && error.fieldErrors!.isNotEmpty) {
        final errorMessages = error.fieldErrors!.entries
            .map((entry) =>
                "${_getReadableFieldName(entry.key)}: ${entry.value}")
            .toList();

        if (errorMessages.length <= 3) {
          // 3 veya daha az hata varsa direkt snackbar ile göster
          SnackbarHelper.showError(
            title: title,
            message: errorMessages.join('\n'),
          );
        } else {
          // Çok fazla hata varsa dialog ile göster
          DialogService.showErrorDialog(
            title: title,
            message: errorMessages.join('\n\n'),
          );
        }
      } else {
        // Sadece genel hata mesajı varsa
        SnackbarHelper.showError(
          title: title,
          message: message,
        );
      }
    }
  }

  /// Alan adlarını daha okunabilir hale getirir
  String _getReadableFieldName(String fieldName) {
    final Map<String, String> fieldNameMap = {
      'email': 'E-posta',
      'password': 'Şifre',
      'firstName': 'Ad',
      'lastName': 'Soyad',
      'username': 'Kullanıcı Adı',
      'phoneNumber': 'Telefon',
      'address': 'Adres',
      'birthDate': 'Doğum Tarihi',
      'amount': 'Tutar',
      'date': 'Tarih',
      'description': 'Açıklama',
      'name': 'İsim',
      'title': 'Başlık',
      'content': 'İçerik',
    };

    if (fieldNameMap.containsKey(fieldName)) {
      return fieldNameMap[fieldName]!;
    }

    if (fieldName.contains('_')) {
      return fieldName
          .split('_')
          .map((word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');
    } else {
      String result = fieldName.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => ' ${match.group(0)}',
      );
      return result.isNotEmpty
          ? result[0].toUpperCase() + result.substring(1)
          : result;
    }
  }
}
