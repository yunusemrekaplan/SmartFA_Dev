import 'package:mobile/app/data/models/request/budget_request_models.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/result.dart';

abstract class IBudgetRepository {
  /// Belirli bir dönemdeki (ay/yıl) bütçeleri getirir.
  Future<Result<List<BudgetModel>, ApiException>> getUserBudgetsByPeriod(int year, int month);

  /// Yeni bir bütçe oluşturur.
  Future<Result<BudgetModel, ApiException>> createBudget(CreateBudgetRequestModel budgetData);

  /// Mevcut bir bütçeyi günceller (sadece tutar).
  Future<Result<void, ApiException>> updateBudget(
      int budgetId, UpdateBudgetRequestModel budgetData);

  /// Belirli bir bütçeyi siler (Soft Delete).
  Future<Result<void, ApiException>> deleteBudget(int budgetId);
}
