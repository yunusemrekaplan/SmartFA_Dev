import 'app_exception.dart';

/// Yerel depolama hataları için exception
class StorageException extends AppException {
  final String? operation;

  const StorageException({
    required super.message,
    this.operation,
    String? code,
    super.details,
  }) : super(code: code ?? 'STORAGE_ERROR');
}
