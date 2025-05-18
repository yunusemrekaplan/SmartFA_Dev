import 'dart:async';

import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';

/// Asenkron operasyonların sonucunu temsil eden soyut temel sınıf.
/// Ya bir başarı değeri (Success) ya da bir hata (Failure) içerir.
abstract class Result<T, E extends Exception> {
  const Result();

  /// Operasyonun başarılı olup olmadığını kontrol eder.
  bool get isSuccess => this is Success<T, E>;

  /// Operasyonun başarısız olup olmadığını kontrol eder.
  bool get isFailure => this is Failure<T, E>;

  /// Başarılı ise veriyi, değilse null döndürür.
  T? get data => isSuccess ? (this as Success<T, E>).data : null;

  /// Başarısız ise hatayı, değilse null döndürür.
  E? get error => isFailure ? (this as Failure<T, E>).error : null;

  /// Sonucu işlemek için bir yol (when'e benzer).
  R when<R>({
    required R Function(T data) success,
    required R Function(E error) failure,
  }) {
    if (isSuccess) {
      return success(data as T);
    } else {
      return failure(error as E);
    }
  }

  /// Sonucu işlemek için bir yol (maybeWhen'e benzer).
  R? maybeWhen<R>({
    R Function(T data)? success,
    R Function(E error)? failure,
    R Function()? orElse,
  }) {
    if (isSuccess && success != null) {
      return success(data as T);
    } else if (isFailure && failure != null) {
      return failure(error as E);
    } else if (orElse != null) {
      return orElse();
    }
    return null;
  }

  /// Future değeri Result'a dönüştürmek için yardımcı metot
  static Future<Result<T, AppException>> fromFuture<T>(
    Future<T> future,
  ) async {
    try {
      final data = await future;
      return Success<T, AppException>(data);
    } on AppException catch (e) {
      return Failure<T, AppException>(e);
    } catch (e) {
      return Failure<T, AppException>(
        UnexpectedException(
          message: 'Beklenmeyen hata: ${e.toString()}',
          details: e,
        ),
      );
    }
  }

  /// Result üzerinde işlem yapmak ve sonucu başka bir Result döndürmek için yardımcı metot
  Future<Result<R, E>> asyncMap<R>(
    Future<R> Function(T data) transform,
  ) async {
    if (isSuccess) {
      try {
        final result = await transform(data as T);
        return Success<R, E>(result);
      } on Exception catch (e) {
        if (e is E) {
          return Failure<R, E>(e);
        }
        throw e; // Transform sırasında beklenmeyen bir hata oluştu
      }
    } else {
      return Failure<R, E>(error as E);
    }
  }

  /// Result üzerinde senkron işlem yapmak ve sonucu başka bir Result döndürmek için yardımcı metot
  Result<R, E> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      try {
        final result = transform(data as T);
        return Success<R, E>(result);
      } on Exception catch (e) {
        if (e is E) {
          return Failure<R, E>(e);
        }
        throw e; // Transform sırasında beklenmeyen bir hata oluştu
      }
    } else {
      return Failure<R, E>(error as E);
    }
  }
}

/// Başarılı bir sonucu temsil eden sınıf.
class Success<T, E extends Exception> extends Result<T, E> {
  @override
  final T data;

  const Success(this.data);

  // Eşitlik kontrolü
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> &&
          runtimeType == other.runtimeType &&
          data == other.data; // Veri eşitliğini kontrol et

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// Başarısız bir sonucu temsil eden sınıf.
class Failure<T, E extends Exception> extends Result<T, E> {
  @override
  final E error;

  const Failure(this.error);

  // Eşitlik kontrolü
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> &&
          runtimeType == other.runtimeType &&
          error == other.error; // Hata eşitliğini kontrol et

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure(error: $error)';
}

// Repository veya servis katmanında Result kullanımı için extension
extension ResultExtensions<T> on Future<T> {
  /// Future'ı Result'a çevirir
  Future<Result<T, AppException>> asResult() async {
    return Result.fromFuture(this);
  }
}

// Repository veya servis katmanında Result listesi kullanımı için extension
extension ListResultExtensions<T> on Future<List<T>> {
  /// Future listesini Result'a çevirir
  Future<Result<List<T>, AppException>> asResult() async {
    return Result.fromFuture(this);
  }
}

// --- Kullanım Örneği (Repository veya Servis içinde) ---
/*
Future<Result<UserModel, ApiException>> getUser(int id) async {
  try {
    final userJson = await remoteDataSource.fetchUser(id);
    final user = UserModel.fromJson(userJson);
    return Success(user); // Başarılı Result döndür
  } on DioException catch (e) {
    return Failure(ApiException.fromDioError(e)); // Başarısız Result döndür
  } catch (e) {
    return Failure(ApiException.fromException(e as Exception));
  }
}
*/

// --- Kullanım Örneği (ViewModel/Controller içinde) ---
/*
Future<void> fetchUserData() async {
  state = LoadingState();
  final result = await userRepository.getUser(123);

  if (result.isSuccess) {
     final user = result.data!; // Başarılı ise data null olmaz (genellikle)
     state = DataLoadedState(user);
  } else {
     final error = result.error!; // Başarısız ise error null olmaz
     state = ErrorState(error.message);
     Get.snackbar('Hata', error.message);
  }

  // Veya when ile:
  // result.when(
  //   success: (user) {
  //      state = DataLoadedState(user);
  //   },
  //   failure: (error) {
  //      state = ErrorState(error.message);
  //      Get.snackbar('Hata', error.message);
  //   }
  // );
}
*/
