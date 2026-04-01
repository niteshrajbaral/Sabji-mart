import '../models/product.dart';
import '../services/api_service.dart';

class ProductRepository {

  final ApiService apiService = ApiService();

  Future<List<Product>> getProducts() async {

    final data = await apiService.fetchStore();

    return data.map((p) => Product.fromJson(p)).toList();
  }
}
