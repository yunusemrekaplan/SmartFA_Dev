import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/debt_remote_datasource.dart';
import 'package:mobile/app/data/models/request/debt_request_models.dart';
import 'package:mobile/app/data/models/response/debt_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/debt_repository.dart';
import 'package:mobile/app/utils/result.dart';

class DebtRepositoryImpl implements IDebtRepository {
  final IDebtRemoteDataSource _remoteDataSource;

  DebtRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<DebtModel>, ApiException>> getUserActiveDebts() async {
    try {
      final debts = await _remoteDataSource.getUserActiveDebts();
      return Success(debts);
    } on DioException catch (e) {
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<DebtModel, ApiException>> getDebtById(int debtId) async {
    try {
      final debt = await _remoteDataSource.getDebtById(debtId);
      return Success(debt);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'Borç bulunamadı.', statusCode: 404));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<DebtModel, ApiException>> createDebt(CreateDebtRequestModel debtData) async {
    try {
      final newDebt = await _remoteDataSource.createDebt(debtData);
      return Success(newDebt);
    } on DioException catch (e) {
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> updateDebt(int debtId, UpdateDebtRequestModel debtData) async {
    try {
      await _remoteDataSource.updateDebt(debtId, debtData);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'Güncellenecek borç bulunamadı.', statusCode: 404));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> deleteDebt(int debtId) async {
    try {
      await _remoteDataSource.deleteDebt(debtId);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'Silinecek borç bulunamadı.', statusCode: 404));
      }
      if (e.response?.statusCode == 400) {
        // İlişkili ödeme hatası
        return Failure(ApiException.fromDioError(e));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }
}
