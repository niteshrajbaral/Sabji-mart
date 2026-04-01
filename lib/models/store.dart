import 'product.dart';

class Store {
  final String id;
  final String businessName;
  final String address;
  final String owner;
  final List<Product> products;

  Store({
    required this.id,
    required this.businessName,
    required this.address,
    required this.owner,
    required this.products,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List;

    List<Product> products =
        productList.map((p) => Product.fromJson(p)).toList();

    return Store(
      id: json['_id'],
      businessName: json['businessName'],
      address: json['address'],
      owner: json['owner'],
      products: products,
    );
  }
}