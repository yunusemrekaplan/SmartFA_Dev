import 'package:mobile/app/data/models/response/auth_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/utils/result.dart';

abstract class IAuthRepository {
  /// Kullanıcı girişi yapar.
  /// Başarılı olursa AuthResponseModel, başarısız olursa AppException içeren Result döner.
  Future<Result<AuthResponseModel, AppException>> login(
      String email, String password);

  /// Yeni kullanıcı kaydı yapar.
  /// Başarılı olursa AuthResponseModel, başarısız olursa AppException içeren Result döner.
  Future<Result<AuthResponseModel, AppException>> register(
      String email, String password, String confirmPassword);

  /// Refresh token kullanarak token yeniler.
  /// Başarılı olursa AuthResponseModel, başarısız olursa AppException içeren Result döner.
  Future<Result<AuthResponseModel, AppException>> refreshToken(
      String refreshToken);

  /// Refresh token'ı iptal eder.
  /// Başarılı olursa void (Result.success), başarısız olursa AppException içeren Result döner.
  Future<Result<void, AppException>> revokeToken(String refreshToken);

  /// Kullanıcının mevcut oturum durumunu kontrol eder.
  /// Token varsa true, yoksa false döner.
  Future<bool> isLoggedIn();

  /// Kullanıcının oturumunu kapatır (tokenları siler).
  /// Başarılı olursa void (Result.success), başarısız olursa AppException içeren Result döner.
  Future<Result<void, AppException>> logout();
}
