import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class CategoryService {
  Future<List<dynamic>> fetchCategories() async {
    final url = "${ApiConfig.baseUrl}/products/categories";
    debugPrint('[CategoryService] Fetching from: $url');
    
    final response = await http.get(
      Uri.parse(url),
    );

    debugPrint('[CategoryService] Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('[CategoryService] Response body length: ${response.body.length} characters');
      debugPrint('[CategoryService] Raw data type: ${data.runtimeType}');
      
      List<dynamic> categoriesList;
      
      if (data is List) {

        categoriesList = data;
      } else if (data is Map) {
     
        debugPrint('[CategoryService] Response keys: ${data.keys.toList()}');
        
        
        if (data.containsKey('categories')) {
          categoriesList = data['categories'] as List<dynamic>;
        } else if (data.containsKey('data')) {
          categoriesList = data['data'] as List<dynamic>;
        } else if (data.containsKey('items')) {
          categoriesList = data['items'] as List<dynamic>;
        } else if (data.containsKey('result')) {
          categoriesList = data['result'] as List<dynamic>;
        } else {
          // Try to find any array field
          final arrayField = data.entries.firstWhere(
            (e) => e.value is List,
            orElse: () => MapEntry('', null),
          );
          if (arrayField.value != null) {
            categoriesList = arrayField.value as List<dynamic>;
          } else {
            throw Exception('Could not find categories array in response');
          }
        }
      } else {
        throw Exception('Unexpected response format: ${data.runtimeType}');
      }
      
      debugPrint('[CategoryService] Parsed ${categoriesList.length} categories');
      
      // Debug: Print raw category data
      for (var i = 0; i < categoriesList.length && i < 5; i++) {
        debugPrint('[CategoryService] Raw category $i: ${categoriesList[i]}');
      }
      
      return categoriesList;
    } else {
      debugPrint('[CategoryService] Error - Status ${response.statusCode}: ${response.reasonPhrase}');
      debugPrint('[CategoryService] Response body: ${response.body}');
      throw Exception("Failed to load categories: ${response.statusCode} ${response.reasonPhrase}");
    }
  }
}
