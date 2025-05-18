import 'app_exception.dart';

/// Veri bulunamadı hatası için exception
class NotFoundException extends AppException {
  final String? resourceType;
  final String? resourceId;

  const NotFoundException({
    required super.message,
    this.resourceType,
    this.resourceId,
    String? code,
    super.details,
  }) : super(code: code ?? 'NOT_FOUND');
}
