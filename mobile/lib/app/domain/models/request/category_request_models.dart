import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/app/domain/models/enums/category_type.dart';

part 'category_request_models.g.dart'; // json_serializable için

// --- Kategori Oluşturma Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class CreateCategoryRequestModel {
  final String name;
  // Enum'ı int'e çeviren helper fonksiyonu kullan
  @JsonKey(toJson: categoryTypeToJson)
  final CategoryType type;
  final String iconName; // İkon zorunlu varsayıldı

  CreateCategoryRequestModel({
    required this.name,
    required this.type,
    required this.iconName,
  });

  Map<String, dynamic> toJson() => _$CreateCategoryRequestModelToJson(this);
}

// --- Kategori Güncelleme Modeli ---
@JsonSerializable(createFactory: false) // Sadece toJson üret
class UpdateCategoryRequestModel {
  final String name;
  final String iconName;

  UpdateCategoryRequestModel({
    required this.name,
    required this.iconName,
  });

  Map<String, dynamic> toJson() => _$UpdateCategoryRequestModelToJson(this);
}
