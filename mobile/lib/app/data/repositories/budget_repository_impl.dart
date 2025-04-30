import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/budget_remote_datasource.dart';
import 'package:mobile/app/data/models/request/budget_request_models.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/utils/result.dart';

class BudgetRepositoryImpl implements IBudgetRepository {
  final IBudgetRemoteDataSource _remoteDataSource;

  BudgetRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<BudgetModel>, ApiException>> getUserBudgetsByPeriod(
      int year, int month) async {
    try {
      final budgets = await _remoteDataSource.getUserBudgetsByPeriod(year, month);
      return Success(budgets);
    } on DioException catch (e) {
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<BudgetModel, ApiException>> createBudget(
      CreateBudgetRequestModel budgetData) async {
    try {
      final newBudget = await _remoteDataSource.createBudget(budgetData);
      return Success(newBudget);
    } on DioException catch (e) {
      // Kategori bulunamadı, zaten bütçe var gibi 400 hataları
      if (e.response?.statusCode == 400) {
        return Failure(ApiException.fromDioError(e));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> updateBudget(
      int budgetId, UpdateBudgetRequestModel budgetData) async {
    try {
      await _remoteDataSource.updateBudget(budgetId, budgetData);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'Güncellenecek bütçe bulunamadı.', statusCode: 404));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> deleteBudget(int budgetId) async {
    try {
      await _remoteDataSource.deleteBudget(budgetId);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'Silinecek bütçe bulunamadı.', statusCode: 404));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }
}
