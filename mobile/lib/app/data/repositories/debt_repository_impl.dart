import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/debt_remote_datasource.dart';
import 'package:mobile/app/data/models/request/debt_request_models.dart';
import 'package:mobile/app/data/models/response/debt_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/debt_repository.dart';
import 'package:mobile/app/utils/exceptions.dart';
import 'package:mobile/app/utils/result.dart';

class DebtRepositoryImpl implements IDebtRepository {
  final IDebtRemoteDataSource _remoteDataSource;

  DebtRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<DebtModel>, AppException>> getUserActiveDebts() async {
    try {
      final debts = await _remoteDataSource.getUserActiveDebts();
      return Success(debts);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<DebtModel, AppException>> getDebtById(int debtId) async {
    try {
      final debt = await _remoteDataSource.getDebtById(debtId);
      return Success(debt);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Borç bulunamadı.',
            resourceType: 'Debt',
            resourceId: debtId.toString()));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<DebtModel, AppException>> createDebt(
      CreateDebtRequestModel debtData) async {
    try {
      final newDebt = await _remoteDataSource.createDebt(debtData);
      return Success(newDebt);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> updateDebt(
      int debtId, UpdateDebtRequestModel debtData) async {
    try {
      await _remoteDataSource.updateDebt(debtId, debtData);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Güncellenecek borç bulunamadı.',
            resourceType: 'Debt',
            resourceId: debtId.toString()));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> deleteDebt(int debtId) async {
    try {
      await _remoteDataSource.deleteDebt(debtId);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Silinecek borç bulunamadı.',
            resourceType: 'Debt',
            resourceId: debtId.toString()));
      }
      if (e.response?.statusCode == 400) {
        // İlişkili ödeme hatası
        return Failure(NetworkException.fromDioError(e));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }
}
