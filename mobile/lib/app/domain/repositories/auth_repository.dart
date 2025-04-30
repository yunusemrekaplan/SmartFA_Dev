import 'package:mobile/app/data/models/response/auth_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/result.dart';

abstract class IAuthRepository {
  /// Kullanıcı girişi yapar.
  /// Başarılı olursa AuthResponseModel, başarısız olursa ApiException içeren Result döner.
  Future<Result<AuthResponseModel, ApiException>> login(
      String email, String password);

  /// Yeni kullanıcı kaydı yapar.
  /// Başarılı olursa AuthResponseModel, başarısız olursa ApiException içeren Result döner.
  Future<Result<AuthResponseModel, ApiException>> register(
      String email, String password, String confirmPassword);

  /// Refresh token kullanarak token yeniler.
  /// Başarılı olursa AuthResponseModel, başarısız olursa ApiException içeren Result döner.
  Future<Result<AuthResponseModel, ApiException>> refreshToken(
      String refreshToken);

  /// Refresh token'ı iptal eder.
  /// Başarılı olursa void (Result.success), başarısız olursa ApiException içeren Result döner.
  Future<Result<void, ApiException>> revokeToken(String refreshToken);

  /// Kullanıcının mevcut oturum durumunu kontrol eder.
  /// Token varsa true, yoksa false döner.
  Future<bool> isLoggedIn();

  /// Kullanıcının oturumunu kapatır (tokenları siler).
  /// Başarılı olursa void (Result.success), başarısız olursa ApiException içeren Result döner.
  Future<Result<void, ApiException>> logout();
}
