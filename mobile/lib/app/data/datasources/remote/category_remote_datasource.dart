// API endpoint yolları
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mobile/app/domain/models/enums/category_type.dart';
import 'package:mobile/app/domain/models/request/category_request_models.dart';
import 'package:mobile/app/domain/models/response/category_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';

const String _categoriesEndpoint = '/categories'; // Ana endpoint

abstract class ICategoryRemoteDataSource {
  /// Belirli bir tipteki kategorileri getirir
  Future<List<CategoryModel>> getCategories(CategoryType type);

  /// Yeni kategori oluşturur
  Future<CategoryModel> createCategory(CreateCategoryRequestModel categoryData);

  /// Varolan kategoriyi günceller
  Future<void> updateCategory(
      int categoryId, UpdateCategoryRequestModel categoryData);

  /// Kategori siler
  Future<void> deleteCategory(int categoryId);

  /// Kullanıcının kategorilerini getirir
  Future<List<CategoryModel>> getUserCategories();
}

class CategoryRemoteDataSource implements ICategoryRemoteDataSource {
  final DioClient _dioClient;

  CategoryRemoteDataSource(this._dioClient);

  @override
  Future<List<CategoryModel>> getCategories(CategoryType type) async {
    try {
      // Enum'ı query parametresi olarak gönder
      final queryParams = {'type': categoryTypeToJson(type)};
      final response = await _dioClient.get(
        _categoriesEndpoint,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      // Dio hataları ErrorInterceptor tarafından işleneceği için tekrar fırlatıyoruz
      rethrow;
    } catch (e) {
      // Hata ayıklama modunda log
      _logError('GetCategories', e);
      // Diğer hataları UnexpectedException olarak sarmalayıp fırlatıyoruz
      throw UnexpectedException(
        message: 'Kategoriler getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<CategoryModel> createCategory(
      CreateCategoryRequestModel categoryData) async {
    try {
      final response = await _dioClient.post(
        _categoriesEndpoint,
        data: categoryData.toJson(),
      );
      return CategoryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('CreateCategory', e);
      throw UnexpectedException(
        message: 'Kategori oluşturulurken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> updateCategory(
      int categoryId, UpdateCategoryRequestModel categoryData) async {
    try {
      await _dioClient.put(
        '$_categoriesEndpoint/$categoryId',
        data: categoryData.toJson(),
      );
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('UpdateCategory', e);
      throw UnexpectedException(
        message: 'Kategori güncellenirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteCategory(int categoryId) async {
    try {
      await _dioClient.delete('$_categoriesEndpoint/$categoryId');
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('DeleteCategory', e);
      throw UnexpectedException(
        message: 'Kategori silinirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<List<CategoryModel>> getUserCategories() async {
    try {
      final response = await _dioClient.get(_categoriesEndpoint);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('GetUserCategories', e);
      throw UnexpectedException(
        message: 'Kategoriler getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  /// Debug modunda hata bilgisini loglar
  void _logError(String operation, Object error) {
    if (kDebugMode) {
      print('CategoryRemoteDataSource $operation Error: $error');
    }
  }
}
