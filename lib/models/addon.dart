/// Addon data model representing additional items that can be added to a product.
class Addon {
  final String id;
  final double price;
  final String name;
  final String description;
  final int maxAvailable;

  Addon({
    required this.id,
    required this.price,
    required this.name,
    required this.description,
    required this.maxAvailable,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['_id'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      maxAvailable: json['maxAvailable'] ?? 0,
    );
  }
}