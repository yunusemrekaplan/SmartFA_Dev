import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';

part 'transaction_request_models.g.dart'; // json_serializable için

// --- İşlem Oluşturma Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class CreateTransactionRequestModel {
  final int accountId;
  final int categoryId;
  final double amount; // Dart'ta double
  // Tarihi backend'e gönderirken genellikle ISO 8601 formatında string tercih edilir.
  @JsonKey(toJson: _dateTimeToJson)
  final DateTime transactionDate;
  final String? notes;

  CreateTransactionRequestModel({
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.transactionDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => _$CreateTransactionRequestModelToJson(this);
}

// --- İşlem Güncelleme Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class UpdateTransactionRequestModel {
  final int accountId;
  final int categoryId;
  final double amount;
  @JsonKey(toJson: _dateTimeToJson)
  final DateTime transactionDate;
  final String? notes;

  UpdateTransactionRequestModel({
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.transactionDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => _$UpdateTransactionRequestModelToJson(this);
}


// DateTime'ı ISO 8601 formatında string'e çeviren yardımcı fonksiyon
String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();

// TransactionFilterDto'yu da buraya ekleyebiliriz veya ayrı bir dosyada tutabiliriz.
// Backend DTO'su ile aynı yapıda.
// Eğer query parametresi olarak gönderilecekse toJson'a ihtiyaç olmayabilir.
class TransactionFilterDto {
  final int? accountId;
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  @JsonKey(fromJson: categoryTypeFromJson)
  final CategoryType? type;
  final int pageNumber;
  final int pageSize;

  TransactionFilterDto({
    this.accountId,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.type,
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  // Query parametreleri için Map oluşturma (toJson gibi)
  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };
    if (accountId != null) params['accountId'] = accountId.toString();
    if (categoryId != null) params['categoryId'] = categoryId.toString();
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    if (type != null) params['type'] = type!.index.toString(); // Enum index'ini gönder
    return params;
  }
}


