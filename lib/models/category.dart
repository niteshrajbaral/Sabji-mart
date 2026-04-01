/// Product category chip data.
class Category {
  final String id;
  final String name;
  final String? color;
  // final int? count;

  Category({
    required this.id,
    required this.name,
    required this.color,
    // this.count,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['_id'] ?? json['id']).toString(),
      name: json['name'] ,
      color: json['color'] ,
      // count: json['count'] ?? '0',
    );
  }
}
