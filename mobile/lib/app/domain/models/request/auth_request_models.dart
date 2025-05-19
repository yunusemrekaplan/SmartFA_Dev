// json_serializable paketini import et
import 'package:json_annotation/json_annotation.dart';

// Kod üretimi için part dosyası
part 'auth_request_models.g.dart'; // json_serializable tarafından üretilecek

// --- Login Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret, fromJson gerekmez
class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  /// Nesneyi JSON map'ine dönüştürür (kod üretici tarafından implemente edilir).
  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}


// --- Register Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class RegisterRequestModel {
  final String email;
  final String password;
  final String confirmPassword;

  RegisterRequestModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  /// Nesneyi JSON map'ine dönüştürür (kod üretici tarafından implemente edilir).
  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}


// --- Refresh Token Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class RefreshTokenRequestModel {
  final String refreshToken;

  RefreshTokenRequestModel({
    required this.refreshToken,
  });

  /// Nesneyi JSON map'ine dönüştürür (kod üretici tarafından implemente edilir).
  Map<String, dynamic> toJson() => _$RefreshTokenRequestModelToJson(this);
}
