// API endpoint yolları
import 'package:dio/dio.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/request/category_request_models.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';

const String _categoriesEndpoint = '/categories'; // Ana endpoint

abstract class ICategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories(CategoryType type);

  Future<CategoryModel> createCategory(CreateCategoryRequestModel categoryData);

  Future<void> updateCategory(int categoryId, UpdateCategoryRequestModel categoryData);

  Future<void> deleteCategory(int categoryId);
}

class CategoryRemoteDataSource implements ICategoryRemoteDataSource {
  final DioClient _dioClient;

  CategoryRemoteDataSource(this._dioClient);

  @override
  Future<List<CategoryModel>> getCategories(CategoryType type) async {
    try {
      // Enum'ı query parametresi olarak gönder (index veya name, backend'e göre)
      final queryParams = {'type': type.index.toString()}; // Örnek: index (0 veya 1)
      final response = await _dioClient.get(
        _categoriesEndpoint,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      print('CategoryRemoteDataSource GetCategories Error: $e');
      rethrow;
    } catch (e) {
      print('CategoryRemoteDataSource GetCategories Unexpected Error: $e');
      throw Exception('Kategoriler getirilirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<CategoryModel> createCategory(CreateCategoryRequestModel categoryData) async {
    try {
      final response = await _dioClient.post(
        _categoriesEndpoint,
        data: categoryData.toJson(),
      );
      return CategoryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('CategoryRemoteDataSource CreateCategory Error: $e');
      rethrow;
    } catch (e) {
      print('CategoryRemoteDataSource CreateCategory Unexpected Error: $e');
      throw Exception('Kategori oluşturulurken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<void> updateCategory(int categoryId, UpdateCategoryRequestModel categoryData) async {
    try {
      await _dioClient.put(
        '$_categoriesEndpoint/$categoryId',
        data: categoryData.toJson(),
      );
    } on DioException catch (e) {
      print('CategoryRemoteDataSource UpdateCategory Error: $e');
      rethrow;
    } catch (e) {
      print('CategoryRemoteDataSource UpdateCategory Unexpected Error: $e');
      throw Exception('Kategori güncellenirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<void> deleteCategory(int categoryId) async {
    try {
      await _dioClient.delete('$_categoriesEndpoint/$categoryId');
    } on DioException catch (e) {
      print('CategoryRemoteDataSource DeleteCategory Error: $e');
      rethrow;
    } catch (e) {
      print('CategoryRemoteDataSource DeleteCategory Unexpected Error: $e');
      throw Exception('Kategori silinirken beklenmedik bir hata oluştu.');
    }
  }
}
