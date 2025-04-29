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
      return Result.success(budgets);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<BudgetModel, ApiException>> createBudget(
      CreateBudgetRequestModel budgetData) async {
    try {
      final newBudget = await _remoteDataSource.createBudget(budgetData);
      return Result.success(newBudget);
    } on DioException catch (e) {
      // Kategori bulunamadı, zaten bütçe var gibi 400 hataları
      if (e.response?.statusCode == 400) {
        return Result.failure(ApiException.fromDioError(e));
      }
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> updateBudget(
      int budgetId, UpdateBudgetRequestModel budgetData) async {
    try {
      await _remoteDataSource.updateBudget(budgetId, budgetData);
      return Result.success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.failure(
            ApiException(message: 'Güncellenecek bütçe bulunamadı.', statusCode: 404));
      }
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> deleteBudget(int budgetId) async {
    try {
      await _remoteDataSource.deleteBudget(budgetId);
      return Result.success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.failure(
            ApiException(message: 'Silinecek bütçe bulunamadı.', statusCode: 404));
      }
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }
}
