import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {

  Future<List<dynamic>> fetchStore() async {

    final url = "${ApiConfig.baseUrl}/products";
    debugPrint('[ApiService] Fetching from: $url');
    
    final response = await http.get(
      Uri.parse(url),
    );

    debugPrint('[ApiService] Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('[ApiService] Response body length: ${response.body.length} characters');
      debugPrint('[ApiService] Raw data type: ${data.runtimeType}');
      
      List<dynamic> productsList;
      
      if (data is List) {
        // Response is directly an array
        productsList = data;
      } else if (data is Map) {
        // Response is an object, look for common array fields
        debugPrint('[ApiService] Response keys: ${data.keys.toList()}');
        
        // Try common field names for product arrays
        if (data.containsKey('products')) {
          productsList = data['products'] as List<dynamic>;
        } else if (data.containsKey('data')) {
          productsList = data['data'] as List<dynamic>;
        } else if (data.containsKey('items')) {
          productsList = data['items'] as List<dynamic>;
        } else if (data.containsKey('result')) {
          productsList = data['result'] as List<dynamic>;
        } else {
          // Try to find any array field
          final arrayField = data.entries.firstWhere(
            (e) => e.value is List,
            orElse: () => MapEntry('', null),
          );
          if (arrayField.value != null) {
            productsList = arrayField.value as List<dynamic>;
          } else {
            throw Exception('Could not find products array in response');
          }
        }
      } else {
        throw Exception('Unexpected response format: ${data.runtimeType}');
      }
      
      debugPrint('[ApiService] Parsed ${productsList.length} products');
      return productsList;
    } else {
      debugPrint('[ApiService] Error - Status ${response.statusCode}: ${response.reasonPhrase}');
      debugPrint('[ApiService] Response body: ${response.body}');
      throw Exception("Failed to load store: ${response.statusCode} ${response.reasonPhrase}");
    }
  }

}
