import 'package:json_annotation/json_annotation.dart';

enum CategoryType {
  @JsonValue(1)
  Income,
  @JsonValue(2)
  Expense,
}

CategoryType categoryTypeFromJson(int type) {
  switch (type) {
    case 1:
      return CategoryType.Income;
    case 2:
      return CategoryType.Expense;
    default:
      print("Uyarı: Bilinmeyen Kategori Türü String'i: $type");
      return CategoryType.Expense; // Veya başka bir varsayılan
  }
}

int categoryTypeToJson(CategoryType type) {
  switch (type) {
    case CategoryType.Income:
      return 1;
    case CategoryType.Expense:
      return 2;
  }
}