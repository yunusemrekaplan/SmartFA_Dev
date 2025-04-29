import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/app/data/models/enums/category_type.dart';

part 'category_response_model.g.dart'; // json_serializable için

@JsonSerializable()
class CategoryModel {
  final int id;
  final String name;
  final CategoryType type; // Enum olarak tanımlandı
  final String? iconName;
  final bool isPredefined;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.iconName,
    required this.isPredefined,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  // Opsiyonel: Eşitlik ve hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CategoryModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              type == other.type &&
              iconName == other.iconName &&
              isPredefined == other.isPredefined;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      iconName.hashCode ^
      isPredefined.hashCode;

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, type: $type, iconName: $iconName, isPredefined: $isPredefined)';
  }
}
