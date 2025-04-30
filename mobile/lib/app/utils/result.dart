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
