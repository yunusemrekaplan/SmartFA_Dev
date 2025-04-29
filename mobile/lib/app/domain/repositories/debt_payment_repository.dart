import 'package:mobile/app/data/models/request/debt_payment_request_models.dart';
import 'package:mobile/app/data/models/response/debt_payment_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/result.dart';

/// Borç ödeme verilerine erişim ve yönetim işlemlerini tanımlayan arayüz.
abstract class IDebtPaymentRepository {
  /// Belirli bir borca ait tüm ödemeleri getirir.
  Future<Result<List<DebtPaymentModel>, ApiException>> getDebtPayments(int debtId);

  /// Belirli bir borca yeni bir ödeme ekler.
  Future<Result<DebtPaymentModel, ApiException>> addDebtPayment(
      CreateDebtPaymentRequestModel paymentData);

// MVP için ödeme silme/güncelleme eklenmedi, gerekirse eklenebilir.
// Future<Result<void, ApiException>> deleteDebtPayment(int paymentId);
}
