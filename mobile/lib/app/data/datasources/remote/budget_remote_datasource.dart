// API endpoint yolları
import 'package:dio/dio.dart';
import 'package:mobile/app/data/models/request/budget_request_models.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';

const String _budgetsEndpoint = '/budgets'; // Ana endpoint

abstract class IBudgetRemoteDataSource {
  Future<List<BudgetModel>> getUserBudgetsByPeriod(int year, int month);

  Future<BudgetModel> createBudget(CreateBudgetRequestModel budgetData);

  Future<void> updateBudget(int budgetId, UpdateBudgetRequestModel budgetData);

  Future<void> deleteBudget(int budgetId);
}

class BudgetRemoteDataSource implements IBudgetRemoteDataSource {
  final DioClient _dioClient;

  BudgetRemoteDataSource(this._dioClient);

  @override
  Future<List<BudgetModel>> getUserBudgetsByPeriod(int year, int month) async {
    try {
      // Yıl ve ayı query parametresi olarak gönder
      final queryParams = {
        'year': year.toString(),
        'month': month.toString(),
      };
      final response = await _dioClient.get(
        _budgetsEndpoint,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => BudgetModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      print('BudgetRemoteDataSource GetUserBudgetsByPeriod Error: $e');
      rethrow; // Repository katmanı ele alacak
    } catch (e) {
      print('BudgetRemoteDataSource GetUserBudgetsByPeriod Unexpected Error: $e');
      throw Exception('Bütçeler getirilirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<BudgetModel> createBudget(CreateBudgetRequestModel budgetData) async {
    try {
      final response = await _dioClient.post(
        _budgetsEndpoint,
        data: budgetData.toJson(),
      );
      return BudgetModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('BudgetRemoteDataSource CreateBudget Error: $e');
      rethrow;
    } catch (e) {
      print('BudgetRemoteDataSource CreateBudget Unexpected Error: $e');
      throw Exception('Bütçe oluşturulurken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<void> updateBudget(int budgetId, UpdateBudgetRequestModel budgetData) async {
    try {
      await _dioClient.put(
        '$_budgetsEndpoint/$budgetId',
        data: budgetData.toJson(),
      );
    } on DioException catch (e) {
      print('BudgetRemoteDataSource UpdateBudget Error: $e');
      rethrow;
    } catch (e) {
      print('BudgetRemoteDataSource UpdateBudget Unexpected Error: $e');
      throw Exception('Bütçe güncellenirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<void> deleteBudget(int budgetId) async {
    try {
      await _dioClient.delete('$_budgetsEndpoint/$budgetId');
    } on DioException catch (e) {
      print('BudgetRemoteDataSource DeleteBudget Error: $e');
      rethrow;
    } catch (e) {
      print('BudgetRemoteDataSource DeleteBudget Unexpected Error: $e');
      throw Exception('Bütçe silinirken beklenmedik bir hata oluştu.');
    }
  }
}
