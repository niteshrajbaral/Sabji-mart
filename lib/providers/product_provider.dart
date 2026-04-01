import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {

  final ProductRepository repository = ProductRepository();

  List<Product> products = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProducts() async {
    debugPrint('[ProductProvider] Starting to load products...');
    
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      products = await repository.getProducts();
      debugPrint('[ProductProvider] Successfully loaded ${products.length} products');
      
      // Debug: Print first 3 products
      for (var i = 0; i < products.length && i < 3; i++) {
        debugPrint('[ProductProvider] Product ${i + 1}: ${products[i].name} - \$${products[i].price}');
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[ProductProvider] Error loading products: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
