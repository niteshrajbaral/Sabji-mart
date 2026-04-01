import 'package:flutter/material.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository repository = CategoryRepository();

  List<Category> categories = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCategories() async {
    debugPrint('[CategoryProvider] Starting to load categories...');
    
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      categories = await repository.getCategories();
      debugPrint('[CategoryProvider] Successfully loaded ${categories.length} categories');
      
      // Debug: Print all categories
      for (var i = 0; i < categories.length; i++) {
        debugPrint('[CategoryProvider] Category ${i + 1}: id=${categories[i].id}, name=${categories[i].name}');
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[CategoryProvider] Error loading categories: $e');
      categories = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Category? getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  String getCategoryName(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.name ?? categoryId;
  }
}