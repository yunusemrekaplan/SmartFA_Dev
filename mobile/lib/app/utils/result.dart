import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart'; // freezed tarafından üretilecek dosya

/// Asenkron operasyonların sonucunu temsil eden sealed class.
/// Başarı durumunda veri (T), hata durumunda Exception içerir.
@freezed
sealed class Result<T, E extends Exception> with _$Result<T, E> {
  // Başarı durumunu temsil eden factory constructor.
  // Veri (data) içerir.
  const factory Result.success(T data) = Success<T, E>;

  // Hata durumunu temsil eden factory constructor.
  // Hata (error) nesnesini içerir.
  const factory Result.failure(E error) = Failure<T, E>;
}


/*
// --- Kullanım Örneği (Repository veya Servis içinde) ---

// Başarılı sonuç döndürme
Future<Result<UserModel, ApiException>> getUser(int id) async {
  try {
    final userJson = await remoteDataSource.fetchUser(id);
    final user = UserModel.fromJson(userJson);
    return Result.success(user); // Başarılı Result döndür
  } on DioException catch (e) {
    // Dio hatasını kendi hata tipimize dönüştür
    return Result.failure(ApiException.fromDioError(e)); // Başarısız Result döndür
  } catch (e) {
    return Result.failure(ApiException(message: 'Beklenmedik hata: $e'));
  }
}

// --- Kullanım Örneği (ViewModel/Controller içinde) ---

Future<void> fetchUserData() async {
  state = LoadingState(); // Durumu yükleniyor yap
  final result = await userRepository.getUser(123);

  // Freezed'ın when, maybeWhen, map, maybeMap metotları ile sonucu işle
  result.when(
    success: (user) {
      state = DataLoadedState(user); // Başarılı durumu güncelle
    },
    failure: (error) {
      state = ErrorState(error.message); // Hata durumunu güncelle
      Get.snackbar('Hata', error.message); // Hata mesajı göster
    },
  );
}
*/

// --- Opsiyonel: Genel Hata Sınıfı ---
// API veya diğer hataları sarmalamak için temel bir Exception sınıfı
// (örn: lib/app/core/errors/exceptions.dart)
/*
class ApiException implements Exception {
  final String message;
  final int? statusCode; // HTTP durum kodu (varsa)

  ApiException({required this.message, this.statusCode});

  // DioException'dan ApiException oluşturma (örnek)
  factory ApiException.fromDioError(DioException dioError) {
    String errorMessage = "Bir ağ hatası oluştu.";
    int? statusCode = dioError.response?.statusCode;

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = "Sunucuya bağlanırken zaman aşımı oluştu.";
        break;
      case DioExceptionType.badResponse:
        // Sunucudan gelen hata mesajını almaya çalış
        if (dioError.response?.data is Map<String, dynamic>) {
          // Backend'in ErrorResponseDto formatına göre ayarla
          final errors = dioError.response?.data['errors'] as List<dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            errorMessage = errors.join('\n');
          } else {
             errorMessage = dioError.response?.data['title'] ?? 'Sunucu hatası: $statusCode';
          }
        } else {
           errorMessage = 'Sunucu hatası: $statusCode';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = "İstek iptal edildi.";
        break;
      case DioExceptionType.connectionError:
         errorMessage = "İnternet bağlantınızı kontrol edin.";
         break;
      case DioExceptionType.unknown:
      default:
        errorMessage = "Bilinmeyen bir hata oluştu.";
        break;
    }
    return ApiException(message: errorMessage, statusCode: statusCode);
  }

  @override
  String toString() => 'ApiException(message: $message, statusCode: $statusCode)';
}
*/

