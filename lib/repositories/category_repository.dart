import '../models/category.dart';
import '../services/category_service.dart';

class CategoryRepository {
  final CategoryService categoryService = CategoryService();

  Future<List<Category>> getCategories() async {
    final data = await categoryService.fetchCategories();
    return data.map((c) => Category.fromJson(c)).toList();
  }
}