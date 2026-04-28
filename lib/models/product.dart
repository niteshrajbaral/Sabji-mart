import 'addon.dart';
import 'composite_item.dart';
import 'variant.dart';

/// Helper function to parse variants which may be a List or a single Map
List<ProductVariant> _parseVariants(dynamic variantsJson) {
  if (variantsJson == null) return [];
  
  // If it's already a List, parse each item
  if (variantsJson is List) {
    return variantsJson
        .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
        .toList();
  }
  
  // If it's a single Map, wrap it in a list
  if (variantsJson is Map) {
    return [ProductVariant.fromJson(Map<String, dynamic>.from(variantsJson))];
  }
  
  return [];
}

/// Product data model.
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double costPrice;
  final bool isVeg;
  final bool isAvailable;
  final bool usesOfferPrice;
  final List<Addon> addons;
  final String adminId;
  final List<CompositeItem> compositeItems;
  final List<ProductVariant> variants;
  final String addedBy;
  final bool isTaxable;
  final int orderedCount;
  final bool showInOrdering;
  final String sku;
  final String soldBy;
  final String image;
  final String description;
  final List<dynamic> tags;
  final bool usesStocks;
  final bool usesCompositeItems;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.costPrice,
    required this.isVeg,
    required this.isAvailable,
    required this.usesOfferPrice,
    required this.addons,
    required this.adminId,
    required this.compositeItems,
    required this.variants,
    required this.addedBy,
    required this.isTaxable,
    required this.orderedCount,
    required this.showInOrdering,
    required this.sku,
    required this.soldBy,
    required this.image,
    required this.description,
    required this.tags,
    required this.usesStocks,
    required this.usesCompositeItems,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      category: json['categories'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      isVeg: json['isVeg'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      usesOfferPrice: json['usesOfferPrice'] ?? false,
      addons: (json['addons'] as List<dynamic>?)
              ?.map((a) => Addon.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      adminId: json['adminId'] ?? '',
      compositeItems: (json['compositeItems'] as List<dynamic>?)
              ?.map((item) => CompositeItem.fromJson(item as Map<String, dynamic>))
              .toList()
          ?? [],
      variants: _parseVariants(json['variants']),
      addedBy: json['added_by'] ?? '',
      isTaxable: json['isTaxable'] ?? false,
      orderedCount: json['orderedCount'] ?? 0,
      showInOrdering: json['showInOrdering'] ?? false,
      sku: json['sku'] ?? '',
      soldBy: json['soldBy'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      tags: json['tags'] ?? [],
      usesStocks: json['usesStocks'] ?? false,
      usesCompositeItems: json['usesCompositeItems'] ?? false,
    );
  }
}

extension ProductDefaults on Product {
  /// Price to show by default: first available variant item's price when the
  /// product has variants, otherwise the base price.
  double get defaultDisplayPrice {
    if (variants.isEmpty || variants.first.variantItems.isEmpty) return price;
    final items = variants.first.variantItems;
    final firstAvailable = items.firstWhere(
      (i) => i.isAvailable,
      orElse: () => items.first,
    );
    return firstAvailable.price;
  }
}
