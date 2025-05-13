// API endpoint yolları
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mobile/app/data/models/request/budget_request_models.dart';
import 'package:mobile/app/data/models/response/budget_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/network/exceptions.dart';

const String _budgetsEndpoint = '/budgets'; // Ana endpoint

abstract class IBudgetRemoteDataSource {
  /// Belirli bir döneme ait bütçeleri getirir
  Future<List<BudgetModel>> getUserBudgetsByPeriod(int year, int month);

  /// Yeni bütçe oluşturur
  Future<BudgetModel> createBudget(CreateBudgetRequestModel budgetData);

  /// Var olan bütçeyi günceller
  Future<void> updateBudget(int budgetId, UpdateBudgetRequestModel budgetData);

  /// Bütçeyi siler
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
      return data
          .map((json) => BudgetModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      // ErrorInterceptor tarafından işlenecek
      rethrow;
    } catch (e) {
      _logError('GetUserBudgetsByPeriod', e);
      throw UnexpectedException(
        message: 'Bütçeler getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
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
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('CreateBudget', e);
      throw UnexpectedException(
        message: 'Bütçe oluşturulurken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> updateBudget(
      int budgetId, UpdateBudgetRequestModel budgetData) async {
    try {
      await _dioClient.put(
        '$_budgetsEndpoint/$budgetId',
        data: budgetData.toJson(),
      );
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('UpdateBudget', e);
      throw UnexpectedException(
        message: 'Bütçe güncellenirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteBudget(int budgetId) async {
    try {
      await _dioClient.delete('$_budgetsEndpoint/$budgetId');
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('DeleteBudget', e);
      throw UnexpectedException(
        message: 'Bütçe silinirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  /// Debug modunda hata loglar
  void _logError(String operation, Object error) {
    if (kDebugMode) {
      print('BudgetRemoteDataSource $operation Error: $error');
    }
  }
}
