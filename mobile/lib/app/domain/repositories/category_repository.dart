import 'package:mobile/app/data/models/enums/category_type.dart';
import 'package:mobile/app/data/models/request/category_request_models.dart';
import 'package:mobile/app/data/models/response/category_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/result.dart';

abstract class ICategoryRepository {
  /// Kullanıcının ve ön tanımlı kategorileri tipe göre getirir.
  Future<Result<List<CategoryModel>, ApiException>> getCategories(CategoryType type);

  /// Yeni bir özel kategori oluşturur.
  Future<Result<CategoryModel, ApiException>> createCategory(
      CreateCategoryRequestModel categoryData);

  /// Mevcut bir özel kategoriyi günceller.
  Future<Result<void, ApiException>> updateCategory(
      int categoryId, UpdateCategoryRequestModel categoryData);

  /// Belirli bir özel kategoriyi siler (Soft Delete).
  Future<Result<void, ApiException>> deleteCategory(int categoryId);
}
