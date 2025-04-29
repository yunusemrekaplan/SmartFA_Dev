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
      return Result.success(debts);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<DebtModel, ApiException>> getDebtById(int debtId) async {
    try {
      final debt = await _remoteDataSource.getDebtById(debtId);
      return Result.success(debt);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.failure(ApiException(message: 'Borç bulunamadı.', statusCode: 404));
      }
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<DebtModel, ApiException>> createDebt(CreateDebtRequestModel debtData) async {
    try {
      final newDebt = await _remoteDataSource.createDebt(debtData);
      return Result.success(newDebt);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> updateDebt(int debtId, UpdateDebtRequestModel debtData) async {
    try {
      await _remoteDataSource.updateDebt(debtId, debtData);
      return Result.success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.failure(
            ApiException(message: 'Güncellenecek borç bulunamadı.', statusCode: 404));
      }
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> deleteDebt(int debtId) async {
    try {
      await _remoteDataSource.deleteDebt(debtId);
      return Result.success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.failure(ApiException(message: 'Silinecek borç bulunamadı.', statusCode: 404));
      }
      if (e.response?.statusCode == 400) {
        // İlişkili ödeme hatası
        return Result.failure(ApiException.fromDioError(e));
      }
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }
}
