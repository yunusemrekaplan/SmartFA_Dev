import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/services/dialog_service.dart';

/// Hesaplar modülündeki UI işlemlerini yöneten servis
/// SRP (Single Responsibility Principle) - UI işlemleri tek bir sınıfta toplanır
class AccountUIService {
  /// Hesap silme onay dialogunu gösterir
  Future<bool?> showDeleteConfirmation(AccountModel account) async {
    return await DialogService.showDeleteConfirmationDialog(
      title: "Hesabı Sil",
      message:
          "'${account.name}' hesabını silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz ve hesaba bağlı tüm işlemler etkilenebilir.",
      onConfirm:
          null, // Dialog kapanınca işlem yapmak istemiyoruz, result'ı kullanacağız
    );
  }

  /// Genel onay dialogu gösterir
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    return await DialogService.showConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm:
          null, // Dialog kapanınca işlem yapmak istemiyoruz, result'ı kullanacağız
    );
  }
}
