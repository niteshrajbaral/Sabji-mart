import 'product.dart';

/// A cart line item: product + quantity + optional variant price.
class CartItem {
  final Product product;
  int quantity;
  /// The price of the selected variant, if any. When null, use product.price.
  final double? variantPrice;
  /// The display name of the selected variant (e.g., "Size: Large").
  final String? variantName;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.variantPrice,
    this.variantName,
  });

  /// Get the effective price for this cart item (variant price or base price).
  double get effectivePrice => variantPrice ?? product.price;
}
