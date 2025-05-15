import 'package:get/get.dart';
import 'package:mobile/app/data/repositories/category_repository_impl.dart';
import 'package:mobile/app/domain/repositories/category_repository.dart';
import 'package:mobile/app/modules/categories/controllers/categories_controller.dart';
import 'package:mobile/app/data/datasources/remote/category_remote_datasource.dart';

class CategoriesBinding implements Bindings {
  @override
  void dependencies() {
    // Datasource
    Get.lazyPut<ICategoryRemoteDataSource>(
      () => CategoryRemoteDataSource(Get.find()),
    );

    // Repository
    Get.lazyPut<ICategoryRepository>(
      () => CategoryRepositoryImpl(Get.find<ICategoryRemoteDataSource>()),
    );

    // Controller
    Get.lazyPut(() => CategoriesController(
          categoryRepository: Get.find<ICategoryRepository>(),
        ));
  }
}
