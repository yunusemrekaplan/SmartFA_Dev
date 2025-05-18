import 'package:mobile/app/data/models/request/debt_payment_request_models.dart';
import 'package:mobile/app/data/models/response/debt_payment_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/utils/result.dart';

/// Borç ödeme verilerine erişim ve yönetim işlemlerini tanımlayan arayüz.
abstract class IDebtPaymentRepository {
  /// Belirli bir borca ait tüm ödemeleri getirir.
  Future<Result<List<DebtPaymentModel>, AppException>> getDebtPayments(
      int debtId);

  /// Belirli bir borca yeni bir ödeme ekler.
  Future<Result<DebtPaymentModel, AppException>> addDebtPayment(
      CreateDebtPaymentRequestModel paymentData);

// MVP için ödeme silme/güncelleme eklenmedi, gerekirse eklenebilir.
// Future<Result<void, AppException>> deleteDebtPayment(int paymentId);
}
