import 'package:get/get.dart';
import 'package:mobile/app/core/services/dialog/i_dialog_service.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';

/// Hesaplar modülündeki UI işlemlerini yöneten servis
/// SRP (Single Responsibility Principle) - UI işlemleri tek bir sınıfta toplanır
class AccountUIService {
  final IDialogService _dialogService = Get.find<IDialogService>();

  /// Hesap silme onay dialogunu gösterir
  Future<bool?> showDeleteConfirmation(AccountModel account) async {
    return await _dialogService.showDeleteConfirmation(
      title: "Hesabı Sil",
      message:
          "'${account.name}' hesabını silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz ve hesaba bağlı tüm işlemler etkilenebilir.",
      onConfirm:
          null, // Dialog kapanınca işlem yapmak istemiyoruz, result'ı kullanacağız
    );
  }
}
