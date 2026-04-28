import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/address.dart';

/// All static data for the app.
abstract final class AppData {


  static const List<Order> recentOrders = [
    Order(
      id: '#WH-4821',
      date: 'Today, 7:30 AM',
      items: [
        OrderItem(name: 'Baby Spinach', image: '🥬', qty: 10),
        OrderItem(name: 'Roma Tomatoes', image: '🍅', qty: 20),
      ],
      total: 115.00,
      status: 'Dispatched',
    ),
    Order(
      id: '#WH-4809',
      date: 'Mar 4, 6:15 AM',
      items: [
        OrderItem(name: 'Watermelon', image: '🍉', qty: 30),
        OrderItem(name: 'Broccoli', image: '🥦', qty: 15),
      ],
      total: 69.00,
      status: 'Delivered',
    ),
    Order(
      id: '#WH-4795',
      date: 'Mar 2, 8:00 AM',
      items: [
        OrderItem(name: 'Alphonso Mangoes', image: '🥭', qty: 5),
      ],
      total: 42.50,
      status: 'Delivered',
    ),
    Order(
      id: '#WH-4780',
      date: 'Feb 28, 7:45 AM',
      items: [
        OrderItem(name: 'Strawberries', image: '🍓', qty: 8),
        OrderItem(name: 'Fresh Basil', image: '🌿', qty: 3),
      ],
      total: 110.00,
      status: 'Delivered',
    ),
  ];

  static final List<Address> _savedAddresses = [
    Address(
      id: 1,
      label: 'Central Depot',
      address: '12 Market Way, Flemington, VIC 3031',
      icon: Icons.factory_outlined,
      type: 'Pickup',
    ),
    Address(
      id: 2,
      label: 'City Restaurant',
      address: '88 Collins Street, Melbourne, VIC 3000',
      icon: Icons.restaurant_outlined,
      type: 'Delivery',
    ),
    Address(
      id: 3,
      label: 'Supermarket Hub',
      address: '240 Bourke Road, Hawthorn, VIC 3122',
      icon: Icons.store_outlined,
      type: 'Delivery',
    ),
  ];

  static List<Address> get savedAddresses => _savedAddresses;

  static int get nextId {
    if (_savedAddresses.isEmpty) return 1;
    return _savedAddresses.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  static void addAddress(Address address) {
    _savedAddresses.add(address);
  }

  static void removeAddress(int id) {
    _savedAddresses.removeWhere((a) => a.id == id);
  }

  static void updateAddress(Address updatedAddress) {
    final index = _savedAddresses.indexWhere((a) => a.id == updatedAddress.id);
    if (index != -1) {
      _savedAddresses[index] = updatedAddress;
    }
  }

  static const List<String> dietaryFilterOptions = [
    'Organic',
    'Seasonal',
    'Local Farm',
    'Premium Grade',
    'Export Quality',
  ];

  static const List<String> dietaryPreferenceOptions = [
    'None',
    'Organic Only',
    'Local Farm',
    'Seasonal',
    'Premium Grade',
    'Export Quality',
    'Certified',
  ];
}
