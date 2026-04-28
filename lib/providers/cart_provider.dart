import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/order.dart';

/// Manages shopping cart state.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, i) => sum + i.effectivePrice * i.quantity);

  static const double deliveryFee = 130;
  double get total => subtotal + deliveryFee;

  bool contains(Product product) =>
      _items.any((i) => i.product.id == product.id);

  void addProduct(
    Product product, {
    int quantity = 1,
    double? variantPrice,
    String? variantName,
    Map<int, int> selectedAddonQuantities = const {},
  }) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
      if (index >= 0) {
        // If the product is already in the cart, update quantity only
        // Only update variant/addon if explicitly provided (do not overwrite with null)
        _items[index].quantity += quantity;
        if (variantPrice != null) {
          _items[index].variantPrice = variantPrice;
        }
        if (variantName != null) {
          _items[index].variantName = variantName;
        }
        if (selectedAddonQuantities.isNotEmpty) {
          _items[index].selectedAddonQuantities = Map<int, int>.from(selectedAddonQuantities);
        }
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        variantPrice: variantPrice,
        variantName: variantName,
        selectedAddonQuantities: selectedAddonQuantities,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(int index, int qty) {
    if (qty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = qty;
    }
    notifyListeners();
  }

  void updateById(String productId, int qty) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;
    if (qty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = qty;
    }
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Finds items from a past order in the provided product list and adds any
  /// that are still available to the current cart.
  ///
  /// Returns a tally of added / unavailable (exists but flagged unavailable) /
  /// missing (no longer in the catalogue) items so the caller can surface
  /// feedback to the user.
  ({int added, int unavailable, int missing}) reorder(
      Order pastOrder, List<Product> availableProducts) {
    int added = 0;
    int unavailable = 0;
    int missing = 0;

    for (final orderItem in pastOrder.items) {
      Product? match;
      for (final p in availableProducts) {
        if (p.name == orderItem.name) {
          match = p;
          break;
        }
      }
      if (match == null) {
        missing++;
        debugPrint(
            '[Cart] reorder: product no longer in catalogue: ${orderItem.name}');
        continue;
      }
      if (!match.isAvailable) {
        unavailable++;
        debugPrint('[Cart] reorder: product unavailable: ${orderItem.name}');
        continue;
      }
      addProduct(match, quantity: orderItem.qty);
      added++;
    }

    return (added: added, unavailable: unavailable, missing: missing);
  }
}
