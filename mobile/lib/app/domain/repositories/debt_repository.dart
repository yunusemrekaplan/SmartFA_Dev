import 'package:mobile/app/data/models/request/debt_request_models.dart';
import 'package:mobile/app/data/models/response/debt_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/result.dart';

/// Borç verilerine erişim ve yönetim işlemlerini tanımlayan arayüz.
abstract class IDebtRepository {
  /// Kullanıcının aktif borçlarını getirir.
  Future<Result<List<DebtModel>, ApiException>> getUserActiveDebts();

  /// Belirli bir borcu ID ile getirir.
  Future<Result<DebtModel, ApiException>> getDebtById(int debtId);

  /// Yeni bir borç oluşturur.
  Future<Result<DebtModel, ApiException>> createDebt(CreateDebtRequestModel debtData);

  /// Mevcut bir borcu günceller (Ad, Alacaklı).
  Future<Result<void, ApiException>> updateDebt(int debtId, UpdateDebtRequestModel debtData);

  /// Belirli bir borcu siler (Soft Delete).
  Future<Result<void, ApiException>> deleteDebt(int debtId);
}
