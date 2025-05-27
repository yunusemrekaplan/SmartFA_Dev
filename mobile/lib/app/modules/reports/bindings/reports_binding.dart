import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../data/repositories/report_repository_impl.dart';
import '../../../data/datasources/remote/report_remote_datasource.dart';
import '../../../domain/repositories/report_repository.dart';
import '../../../data/network/dio_client.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    // DioClient zaten uygulama genelinde singleton olarak kayıtlı olmalı

    // Remote Data Source
    Get.lazyPut<IReportRemoteDataSource>(
      () => ReportRemoteDataSource(Get.find<DioClient>()),
    );

    // Repository
    Get.lazyPut<IReportRepository>(
      () => ReportRepositoryImpl(Get.find<IReportRemoteDataSource>()),
    );

    // Controller
    Get.lazyPut<ReportsController>(
      () => ReportsController(Get.find<IReportRepository>()),
    );
  }
}
