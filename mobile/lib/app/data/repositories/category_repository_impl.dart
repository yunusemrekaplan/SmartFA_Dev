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
  Future<Result<List<CategoryModel>, AppException>> getCategories(
      CategoryType type) async {
    try {
      final categories = await _remoteDataSource.getCategories(type);
      return Success(categories);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<CategoryModel, AppException>> createCategory(
      CreateCategoryRequestModel categoryData) async {
    try {
      final newCategory = await _remoteDataSource.createCategory(categoryData);
      return Success(newCategory);
    } on DioException catch (e) {
      // İsim çakışması (400 Bad Request) gibi durumları özel ele alabiliriz
      if (e.response?.statusCode == 400) {
        return Failure(ValidationException(
            message: 'Kategori oluşturma hatası',
            fieldErrors: e.response?.data['errors']));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> updateCategory(
      int categoryId, UpdateCategoryRequestModel categoryData) async {
    try {
      await _remoteDataSource.updateCategory(categoryId, categoryData);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Güncellenecek kategori bulunamadı.',
            resourceType: 'Category',
            resourceId: categoryId.toString()));
      }
      if (e.response?.statusCode == 400) {
        // İsim çakışması vb.
        return Failure(ValidationException(
            message: 'Kategori güncelleme hatası',
            fieldErrors: e.response?.data['errors']));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> deleteCategory(int categoryId) async {
    try {
      await _remoteDataSource.deleteCategory(categoryId);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Silinecek kategori bulunamadı.',
            resourceType: 'Category',
            resourceId: categoryId.toString()));
      }
      if (e.response?.statusCode == 400) {
        // İlişkili veri hatası
        return Failure(NetworkException.fromDioError(e));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<List<CategoryModel>, AppException>> getUserCategories() async {
    try {
      final categories = await _remoteDataSource.getUserCategories();
      return Success(categories);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }
}
