import 'package:mobile/app/domain/models/request/budget_request_models.dart';
import 'package:mobile/app/domain/models/response/budget_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/utils/result.dart';

abstract class IBudgetRepository {
  /// Belirli bir dönemdeki (ay/yıl) bütçeleri getirir.
  Future<Result<List<BudgetModel>, AppException>> getUserBudgetsByPeriod(
      int year, int month);

  /// Yeni bir bütçe oluşturur.
  Future<Result<BudgetModel, AppException>> createBudget(
      CreateBudgetRequestModel budgetData);

  /// Mevcut bir bütçeyi günceller (sadece tutar).
  Future<Result<void, AppException>> updateBudget(
      int budgetId, UpdateBudgetRequestModel budgetData);

  /// Belirli bir bütçeyi siler (Soft Delete).
  Future<Result<void, AppException>> deleteBudget(int budgetId);
}
