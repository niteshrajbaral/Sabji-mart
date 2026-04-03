/// CompositeItem data model representing items in a composite product.
class CompositeItem {
  final String compositeProduct;
  final String name;
  final int quantity;
  final String image;

  CompositeItem({
    required this.compositeProduct,
    required this.name,
    required this.quantity,
    this.image = '',
  });

  factory CompositeItem.fromJson(Map<String, dynamic> json) {
    return CompositeItem(
      compositeProduct: json['compositeProduct'] ?? '',
      name: json['name'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      image: json['image'] ?? '',
    );
  }
}
