import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/budget_remote_datasource.dart';
import 'package:mobile/app/data/models/request/budget_request_models.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/network_exception.dart';
import 'package:mobile/app/data/network/exceptions/not_found_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/data/network/exceptions/validation_exception.dart';
import 'package:mobile/app/domain/repositories/budget_repository.dart';
import 'package:mobile/app/utils/result.dart';

class BudgetRepositoryImpl implements IBudgetRepository {
  final IBudgetRemoteDataSource _remoteDataSource;

  BudgetRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<BudgetModel>, AppException>> getUserBudgetsByPeriod(
      int year, int month) async {
    try {
      final budgets = await _remoteDataSource.getUserBudgetsByPeriod(year, month);
      return Success(budgets);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<BudgetModel, AppException>> createBudget(
      CreateBudgetRequestModel budgetData) async {
    try {
      final newBudget = await _remoteDataSource.createBudget(budgetData);
      return Success(newBudget);
    } on DioException catch (e) {
      // Kategori bulunamadı, zaten bütçe var gibi 400 hataları
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          Map<String, String> fieldErrors = {};

          try {
            final errors = data['errors'] as Map<String, dynamic>;
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                fieldErrors[key] = value.first.toString();
              } else if (value is String) {
                fieldErrors[key] = value;
              }
            });

            // Bütçe kategorisi bulunamadı veya zaten var gibi özel durumları ele al
            if (fieldErrors.containsKey('categoryId')) {
              return Failure(ValidationException(
                  message: 'Kategori ile ilgili bir hata oluştu: ${fieldErrors['categoryId']}',
                  fieldErrors: fieldErrors));
            }

            return Failure(ValidationException(
                message: 'Bütçe bilgileri geçersiz.', fieldErrors: fieldErrors));
          } catch (_) {}
        }
      }

      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> updateBudget(
      int budgetId, UpdateBudgetRequestModel budgetData) async {
    try {
      await _remoteDataSource.updateBudget(budgetId, budgetData);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Güncellenecek bütçe bulunamadı.',
            resourceType: 'Budget',
            resourceId: budgetId.toString()));
      }

      // Validasyon hatalarını ele al
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          Map<String, String> fieldErrors = {};

          try {
            final errors = data['errors'] as Map<String, dynamic>;
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                fieldErrors[key] = value.first.toString();
              } else if (value is String) {
                fieldErrors[key] = value;
              }
            });

            return Failure(ValidationException(
                message: 'Bütçe güncelleme bilgileri geçersiz.', fieldErrors: fieldErrors));
          } catch (_) {}
        }
      }

      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> deleteBudget(int budgetId) async {
    try {
      await _remoteDataSource.deleteBudget(budgetId);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Silinecek bütçe bulunamadı.',
            resourceType: 'Budget',
            resourceId: budgetId.toString()));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }
}
