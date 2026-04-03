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
      
      // Debug: Print all products with their usesCompositeItems status
      debugPrint('[ProductProvider] === PRODUCT LIST ===');
      int compositeCount = 0;
      for (var i = 0; i < products.length; i++) {
        final product = products[i];
        debugPrint('[ProductProvider] Product ${i + 1}: ${product.name} - Rs ${product.price}');
        debugPrint('[ProductProvider]   ID: ${product.id}');
        debugPrint('[ProductProvider]   usesCompositeItems: ${product.usesCompositeItems}');
        debugPrint('[ProductProvider]   compositeItems count: ${product.compositeItems.length}');
        if (product.usesCompositeItems) {
          compositeCount++;
          debugPrint('[ProductProvider]   *** COMPOSITE PRODUCT ***');
          if (product.compositeItems.isNotEmpty) {
            for (var item in product.compositeItems) {
              debugPrint('[ProductProvider]     - ${item.name} (qty: ${item.quantity})');
            }
          }
        }
      }
      debugPrint('[ProductProvider] === END PRODUCT LIST ===');
      debugPrint('[ProductProvider] Total composite products: $compositeCount');
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[ProductProvider] Error loading products: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
