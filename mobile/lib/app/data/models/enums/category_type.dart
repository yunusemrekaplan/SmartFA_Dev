import 'package:json_annotation/json_annotation.dart';

enum CategoryType {
  @JsonValue(1)
  Expense,
  @JsonValue(2)
  Income,
}

CategoryType categoryTypeFromJson(int type) {
  switch (type) {
    case 1:
      return CategoryType.Expense;
    case 2:
      return CategoryType.Income;
    default:
      print("Uyarı: Bilinmeyen Kategori Türü String'i: $type");
      return CategoryType.Expense; // Veya başka bir varsayılan
  }
}

int categoryTypeToJson(CategoryType type) {
  switch (type) {
    case CategoryType.Expense:
      return 1;
    case CategoryType.Income:
      return 2;
  }
}

extension CategoryTypeExtension on CategoryType {
  String get name {
    switch (this) {
      case CategoryType.Expense:
        return 'Gider';
      case CategoryType.Income:
        return 'Gelir';
    }
  }

  /// Kategori türünün gelir olup olmadığını kontrol eder
  bool get isIncome => this == CategoryType.Income;

  /// Kategori türünün gider olup olmadığını kontrol eder
  bool get isExpense => this == CategoryType.Expense;
}
