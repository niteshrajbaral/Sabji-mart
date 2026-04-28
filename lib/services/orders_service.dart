import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'auth_service.dart';

/// Fetches the logged-in user's past orders.
class OrdersService {
  final AuthService _authService = AuthService();

  /// GET /api/ticket/my-orders
  Future<List<Order>> fetchMyOrders() async {
    try {
      final url =
          Uri.parse('https://api.beta.order.rebuzzpos.com/api/ticket/my-orders');
      final token = await _authService.getSessionToken();

      debugPrint('[OrdersService] Fetching my orders'
          ' (token length=${token?.length ?? 0})');

      if (token == null || token.isEmpty) {
        throw Exception('Not signed in');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'app': 'customer',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
          '[OrdersService] my-orders response: ${response.statusCode}');
      if (response.statusCode >= 400) {
        debugPrint('[OrdersService] error body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // The endpoint may return either a bare list or {data: [...]}
        final List<dynamic> list = body is List
            ? body
            : (body is Map && body['data'] is List
                ? body['data'] as List
                : const []);
        final orders = list
            .whereType<Map>()
            .map((m) => Order.fromJson(Map<String, dynamic>.from(m)))
            .toList();
        debugPrint(
            '[OrdersService] parsed ${orders.length} orders; businessIds=${orders.map((o) => o.businessId).toSet()}');
        return orders;
      }

      throw Exception('Failed to load orders: ${response.statusCode}');
    } catch (e) {
      debugPrint('[OrdersService] fetchMyOrders error: $e');
      rethrow;
    }
  }
}
