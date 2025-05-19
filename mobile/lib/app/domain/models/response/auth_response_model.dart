import 'package:json_annotation/json_annotation.dart';

// Kod üretimi için part dosyası (sadece json_serializable için)
part 'auth_response_model.g.dart';

@JsonSerializable() // fromJson ve toJson üretmek için
class AuthResponseModel {
  final String accessToken;
  final String userId;
  final String email;
  final String refreshToken;

  // Constructor
  AuthResponseModel({
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.refreshToken,
  });

  // JSON'dan nesne oluşturmak için factory constructor (json_serializable üretecek)
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  // Nesneyi JSON'a dönüştürmek için metot (json_serializable üretecek)
  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  // Opsiyonel: Eşitlik ve hashCode (manuel veya equatable paketi ile)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AuthResponseModel &&
              runtimeType == other.runtimeType &&
              accessToken == other.accessToken &&
              userId == other.userId &&
              email == other.email &&
              refreshToken == other.refreshToken;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      userId.hashCode ^
      email.hashCode ^
      refreshToken.hashCode;

  @override
  String toString() {
    return 'AuthResponseModel(accessToken: $accessToken, userId: $userId, email: $email, refreshToken: $refreshToken)';
  }
}
