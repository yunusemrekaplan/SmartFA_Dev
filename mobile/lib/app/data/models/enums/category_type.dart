import 'package:json_annotation/json_annotation.dart';

enum CategoryType {
  @JsonValue(1)
  Income,
  @JsonValue(2)
  Expense,
}

CategoryType categoryTypeFromString(String typeString) {
  switch (typeString.toLowerCase()) {
    case 'income':
      return CategoryType.Income;
    case 'expense':
      return CategoryType.Expense;
    default:
      print("Uyarı: Bilinmeyen Kategori Türü String'i: $typeString");
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