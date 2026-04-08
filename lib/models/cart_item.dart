import 'product.dart';

/// A cart line item: product + quantity + optional variant price + addon selections.
class CartItem {
  final Product product;
  int quantity;
  /// The price of the selected variant, if any. When null, use product.price.
  double? variantPrice;
  /// The display name of the selected variant (e.g., "Size: Large").
  String? variantName;
  /// Map of addon index to quantity selected (e.g., {0: 2, 1: 1} means 2x of first addon, 1x of second)
  Map<int, int> selectedAddonQuantities;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.variantPrice,
    this.variantName,
    Map<int, int>? selectedAddonQuantities,
  }) : selectedAddonQuantities = selectedAddonQuantities ?? const {};

  /// Get the effective price for this cart item (variant price + addons).
  double get effectivePrice {
    double basePrice = variantPrice ?? product.price;
    double addonsPrice = 0.0;
    
    selectedAddonQuantities.forEach((addonIndex, quantity) {
      if (quantity > 0 && addonIndex < product.addons.length) {
        addonsPrice += product.addons[addonIndex].price * quantity;
      }
    });
    
    return basePrice + addonsPrice;
  }
}
