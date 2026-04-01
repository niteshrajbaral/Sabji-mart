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
  final List<dynamic> addons;
  final String adminId;
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
      addons: json['addons'] ?? [],
      adminId: json['adminId'] ?? '',
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
    );
  }
}
