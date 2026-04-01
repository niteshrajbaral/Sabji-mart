import 'product.dart';

/// A cart line item: product + quantity.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
