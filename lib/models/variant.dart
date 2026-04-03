/// Represents an option group (e.g., Size, Color) with title and available values.
class ProductOption {
  final String id;
  final String title;
  final List<String> values;

  ProductOption({
    required this.id,
    required this.title,
    required this.values,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      values: (json['values'] as List<dynamic>?)
              ?.map((v) => v.toString())
              .toList() ??
          [],
    );
  }
}

/// Represents a specific variant item with option values, price, and availability.
class VariantItem {
  final String id;
  final List<String> optionValues;
  final double price;
  final double costPrice;
  final bool isAvailable;
  final int? inStock;
  final int? lowStock;

  VariantItem({
    required this.id,
    required this.optionValues,
    required this.price,
    required this.costPrice,
    required this.isAvailable,
    this.inStock,
    this.lowStock,
  });

  factory VariantItem.fromJson(Map<String, dynamic> json) {
    return VariantItem(
      id: json['_id'] ?? '',
      optionValues: (json['optionValues'] as List<dynamic>?)
              ?.map((v) => v.toString())
              .toList() ??
          [],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? false,
      inStock: json['inStock'] as int?,
      lowStock: json['lowStock'] as int?,
    );
  }
}

/// Represents a complete variant configuration with options and variant items.
class ProductVariant {
  final String id;
  final String productId;
  final List<ProductOption> options;
  final List<VariantItem> variantItems;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.options,
    required this.variantItems,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id'] ?? '',
      productId: json['productId'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => ProductOption.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      variantItems: (json['variantItems'] as List<dynamic>?)
              ?.map((v) => VariantItem.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}