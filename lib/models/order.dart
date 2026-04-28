/// An item in a past order.
class OrderItem {
  final String name;
  final String image;
  final int qty;

  const OrderItem({
    required this.name,
    required this.image,
    required this.qty,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: (json['productName'] ?? json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      qty: (json['quantity'] ?? json['qty'] ?? 1) is int
          ? (json['quantity'] ?? json['qty'] ?? 1) as int
          : int.tryParse('${json['quantity'] ?? json['qty'] ?? 1}') ?? 1,
    );
  }
}

/// A completed/past order record.
class Order {
  final String id;
  final String date;
  final List<OrderItem> items;
  final double total;
  final String status;
  final int? invoice;
  final String? businessId;

  const Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    this.invoice,
    this.businessId,
  });

  /// Parses an order from the /api/ticket/my-orders response shape.
  /// The API nests line items under `items[].item[]` (one ticket may hold
  /// multiple items), so we flatten them into a single OrderItem list.
  factory Order.fromJson(Map<String, dynamic> json) {
    final ticketList = (json['items'] as List?) ?? const [];

    final List<OrderItem> flat = [];
    String? earliestCreatedAt;

    for (final ticket in ticketList) {
      if (ticket is! Map) continue;
      final createdAt = ticket['createdAt']?.toString();
      if (createdAt != null &&
          (earliestCreatedAt == null || createdAt.compareTo(earliestCreatedAt) < 0)) {
        earliestCreatedAt = createdAt;
      }
      final itemList = (ticket['item'] as List?) ?? const [];
      for (final it in itemList) {
        if (it is Map) {
          flat.add(OrderItem.fromJson(Map<String, dynamic>.from(it)));
        }
      }
    }

    final rawTotal = json['total'];
    final total = rawTotal is num
        ? rawTotal.toDouble()
        : double.tryParse('${rawTotal ?? 0}') ?? 0.0;

    final rawInvoice = json['invoice'];
    final invoice = rawInvoice is int
        ? rawInvoice
        : int.tryParse('${rawInvoice ?? ''}');

    return Order(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      date: earliestCreatedAt ?? '',
      items: flat,
      total: total,
      status: (json['paidStatus'] ?? json['status'] ?? '').toString(),
      invoice: invoice,
      businessId: _extractBusinessId(json, ticketList),
    );
  }

  /// businessId may come as a plain string, as a nested Mongo object
  /// (`{_id: "..."}`), under a differently-named key, or only inside one of
  /// the nested tickets — search all of those locations.
  static String? _extractBusinessId(
      Map<String, dynamic> json, List<dynamic> ticketList) {
    String? pick(dynamic v) {
      if (v == null) return null;
      if (v is String) return v.isEmpty ? null : v;
      if (v is Map) {
        final nested = v['_id'] ?? v['id'] ?? v['oid'] ?? v[r'$oid'];
        if (nested is String && nested.isNotEmpty) return nested;
        return null;
      }
      final s = v.toString();
      return s.isEmpty ? null : s;
    }

    for (final key in const [
      'businessId',
      'business_id',
      'business',
      'shopId',
      'storeId',
    ]) {
      final hit = pick(json[key]);
      if (hit != null) return hit;
    }
    for (final ticket in ticketList) {
      if (ticket is! Map) continue;
      for (final key in const ['businessId', 'business_id', 'business']) {
        final hit = pick(ticket[key]);
        if (hit != null) return hit;
      }
    }
    return null;
  }
}
