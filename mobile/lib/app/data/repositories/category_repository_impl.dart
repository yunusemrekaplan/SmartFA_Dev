import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/category_remote_datasource.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/request/category_request_models.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/utils/result.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final ICategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<CategoryModel>, ApiException>> getCategories(CategoryType type) async {
    try {
      final categories = await _remoteDataSource.getCategories(type);
      return Result.success(categories);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<CategoryModel, ApiException>> createCategory(
      CreateCategoryRequestModel categoryData) async {
    try {
      final newCategory = await _remoteDataSource.createCategory(categoryData);
      return Result.success(newCategory);
    } on DioException catch (e) {
      // İsim çakışması (400 Bad Request) gibi durumları özel ele alabiliriz
      if (e.response?.statusCode == 400) {
        return Result.failure(ApiException.fromDioError(e)); // Backend'den gelen mesajı kullan
      }
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> updateCategory(
      int categoryId, UpdateCategoryRequestModel categoryData) async {
    try {
      await _remoteDataSource.updateCategory(categoryId, categoryData);
      return Result.success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.failure(
            ApiException(message: 'Güncellenecek kategori bulunamadı.', statusCode: 404));
      }
      if (e.response?.statusCode == 400) {
        // İsim çakışması vb.
        return Result.failure(ApiException.fromDioError(e));
      }
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> deleteCategory(int categoryId) async {
    try {
      await _remoteDataSource.deleteCategory(categoryId);
      return Result.success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.failure(
            ApiException(message: 'Silinecek kategori bulunamadı.', statusCode: 404));
      }
      if (e.response?.statusCode == 400) {
        // İlişkili veri hatası
        return Result.failure(ApiException.fromDioError(e));
      }
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }
}
