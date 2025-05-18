import 'package:mobile/app/data/models/request/debt_request_models.dart';
import 'package:mobile/app/data/models/response/debt_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/utils/result.dart';

/// Borç verilerine erişim ve yönetim işlemlerini tanımlayan arayüz.
abstract class IDebtRepository {
  /// Kullanıcının aktif borçlarını getirir.
  Future<Result<List<DebtModel>, AppException>> getUserActiveDebts();

  /// Belirli bir borcu ID ile getirir.
  Future<Result<DebtModel, AppException>> getDebtById(int debtId);

  /// Yeni bir borç oluşturur.
  Future<Result<DebtModel, AppException>> createDebt(
      CreateDebtRequestModel debtData);

  /// Mevcut bir borcu günceller (Ad, Alacaklı).
  Future<Result<void, AppException>> updateDebt(
      int debtId, UpdateDebtRequestModel debtData);

  /// Belirli bir borcu siler (Soft Delete).
  Future<Result<void, AppException>> deleteDebt(int debtId);
}
