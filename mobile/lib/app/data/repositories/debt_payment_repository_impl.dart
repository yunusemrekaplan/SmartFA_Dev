import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/debt_payment_remote_datasource.dart';
import 'package:mobile/app/data/models/request/debt_payment_request_models.dart';
import 'package:mobile/app/data/models/response/debt_payment_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/network_exception.dart';
import 'package:mobile/app/data/network/exceptions/not_found_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/data/network/exceptions/validation_exception.dart';
import 'package:mobile/app/domain/repositories/debt_payment_repository.dart';
import 'package:mobile/app/utils/result.dart';

class DebtPaymentRepositoryImpl implements IDebtPaymentRepository {
  final IDebtPaymentRemoteDataSource _remoteDataSource;

  DebtPaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<DebtPaymentModel>, AppException>> getDebtPayments(int debtId) async {
    try {
      final payments = await _remoteDataSource.getDebtPayments(debtId);
      return Success(payments);
    } on DioException catch (e) {
      // Borç bulunamadı hatası (404)
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'İlgili borç bulunamadı.',
            resourceType: 'Debt',
            resourceId: debtId.toString()));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<DebtPaymentModel, AppException>> addDebtPayment(
      CreateDebtPaymentRequestModel paymentData) async {
    try {
      final newPayment = await _remoteDataSource.addDebtPayment(paymentData);
      return Success(newPayment);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Borç bulunamadı
        return Failure(NotFoundException(
            message: 'Ödeme yapılacak borç bulunamadı.',
            resourceType: 'Debt',
            resourceId: paymentData.debtId.toString()));
      }
      if (e.response?.statusCode == 400) {
        // Fazla ödeme, zaten ödenmiş vb.
        return Failure(ValidationException(
            message: 'Ödeme yapılacak borç bulunamadı.', fieldErrors: e.response?.data['errors']));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }
}
