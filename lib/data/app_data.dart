import '../models/product.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/address.dart';

/// All static data for the app.
abstract final class AppData {
//   static final List<Category> categories = [
//     Category(id: 'fruits', name: 'Fruits', icon: '🍎'),
//     Category(id: 'vegetables', name: 'Vegetables', icon: '🥦'),
//     Category(id: 'leafy', name: 'Leafy Greens', icon: '🥬'),
//     Category(id: 'herbs', name: 'Herbs', icon: '🌿'),
//     Category(id: 'exotic', name: 'Exotic', icon: '🥭'),
//   ];

//   static const List<Product> products = [];

  // static const List<Product> products = [
  //   Product(
  //     id: 1,
  //     name: 'Watermelon',
  //     category: 'fruits',
  //     price: 1.20,
  //     rating: 4.8,
  //     reviews: 210,
  //     image: 'assets/images/watermelon.png',
  //     badge: 'Bestseller',
  //     description:
  //         'Premium seedless watermelons, sweet and juicy. Ideal for retail and foodservice. Sourced from sun-ripened farms. Available in 10 kg and 20 kg crates.',
  //     tags: ['Seasonal', 'Local Farm'],
  //     time: 'Min. 10 kg',
  //   ),
  //   Product(
  //     id: 2,
  //     name: 'Roma Tomatoes',
  //     category: 'vegetables',
  //     price: 2.50,
  //     rating: 4.7,
  //     reviews: 185,
  //     image: 'assets/images/tomatoes.png',
  //     badge: 'Popular',
  //     description:
  //         'Grade A Roma tomatoes with firm flesh and rich flavour. Perfect for sauces, salads and catering. Packed in 5 kg trays.',
  //     tags: ['Organic', 'Export Quality'],
  //     time: 'Min. 5 kg',
  //   ),
  //   Product(
  //     id: 3,
  //     name: 'Baby Spinach',
  //     category: 'leafy',
  //     price: 6.50,
  //     rating: 4.9,
  //     reviews: 142,
  //     image: 'assets/images/baby-spinach.png',
  //     badge: 'Organic',
  //     description:
  //         'Tender baby spinach leaves, triple-washed and ready for use. High in iron and vitamins. Packed in 1 kg bags, minimum 5 kg order.',
  //     tags: ['Organic', 'Premium Grade'],
  //     time: 'Min. 5 kg',
  //   ),
  //   Product(
  //     id: 4,
  //     name: 'Carrots',
  //     category: 'vegetables',
  //     price: 1.80,
  //     rating: 4.6,
  //     reviews: 167,
  //     image: 'assets/images/carrot.png',
  //     badge: null,
  //     description:
  //         'Fresh Dutch carrots, naturally sweet with vibrant orange colour. Washed and graded. Available loose or in 10 kg bags.',
  //     tags: ['Local Farm', 'Seasonal'],
  //     time: 'Min. 10 kg',
  //   ),
  //   Product(
  //     id: 5,
  //     name: 'Alphonso Mangoes',
  //     category: 'exotic',
  //     price: 8.50,
  //     rating: 5.0,
  //     reviews: 298,
  //     image: 'assets/images/mango.png',
  //     badge: 'Premium',
  //     description:
  //         'King of mangoes — Alphonso variety with intensely sweet, saffron-coloured flesh. Imported directly. Sold in trays of 12 pieces.',
  //     tags: ['Export Quality', 'Premium Grade'],
  //     time: 'Tray of 12',
  //   ),
  //   Product(
  //     id: 6,
  //     name: 'Broccoli',
  //     category: 'vegetables',
  //     price: 2.20,
  //     rating: 4.7,
  //     reviews: 109,
  //     image: 'assets/images/broccoli.png',
  //     badge: null,
  //     description:
  //         'Dense, dark-green florets with thick stalks. Sourced from high-altitude farms for superior crunch. Packed in 5 kg boxes.',
  //     tags: ['Local Farm', 'Organic'],
  //     time: 'Min. 5 kg',
  //   ),
  //   Product(
  //     id: 7,
  //     name: 'Fresh Basil',
  //     category: 'herbs',
  //     price: 18.00,
  //     rating: 4.8,
  //     reviews: 76,
  //     image: 'assets/images/fresh-basil.png',
  //     badge: 'Bestseller',
  //     description:
  //         'Fragrant Italian sweet basil, harvested at peak flavour. Supplied in 200 g bunches. Essential for restaurants and delis.',
  //     tags: ['Organic', 'Premium Grade'],
  //     time: 'Min. 1 kg',
  //   ),
  //   Product(
  //     id: 8,
  //     name: 'Strawberries',
  //     category: 'fruits',
  //     price: 7.00,
  //     rating: 4.9,
  //     reviews: 234,
  //     image: 'assets/images/strawberry.png',
  //     badge: 'New Season',
  //     description:
  //         'Plump, ripe strawberries with full sweetness and bright red colour. Class 1 grade, packed in 500 g punnets. 4 kg per tray.',
  //     tags: ['Seasonal', 'Export Quality'],
  //     time: 'Min. 4 kg',
  //   ),
  //   Product(
  //     id: 9,
  //     name: 'Iceberg Lettuce',
  //     category: 'leafy',
  //     price: 1.50,
  //     rating: 4.5,
  //     reviews: 98,
  //     image: 'assets/images/iceberg-lattice.png',
  //     badge: null,
  //     description:
  //         'Crisp, tightly-packed iceberg heads. Long shelf life and high water content. Ideal for food service. Sold per head or in boxes of 12.',
  //     tags: ['Local Farm'],
  //     time: 'Min. 12 heads',
  //   ),
  //   Product(
  //     id: 10,
  //     name: 'Pineapple',
  //     category: 'exotic',
  //     price: 3.20,
  //     rating: 4.7,
  //     reviews: 121,
  //     image: 'assets/images/pineapple.png',
  //     badge: null,
  //     description:
  //         'Sweet Queen pineapples from tropical farms. Rich in bromelain and vitamin C. Supplied whole, 6–8 pieces per box.',
  //     tags: ['Export Quality', 'Seasonal'],
  //     time: 'Box of 6–8',
  //   ),
  //   Product(
  //     id: 11,
  //     name: 'Red Capsicum',
  //     category: 'vegetables',
  //     price: 3.80,
  //     rating: 4.6,
  //     reviews: 88,
  //     image: 'assets/images/red-capsicum.png',
  //     badge: 'Popular',
  //     description:
  //         'Jumbo red capsicums with thick walls, bright colour and sweet flavour. Class 1. Packed in 5 kg cartons.',
  //     tags: ['Organic', 'Premium Grade'],
  //     time: 'Min. 5 kg',
  //   ),
  //   Product(
  //     id: 12,
  //     name: 'Fresh Coriander',
  //     category: 'herbs',
  //     price: 12.00,
  //     rating: 4.8,
  //     reviews: 65,
  //     image: 'assets/images/coriander.png',
  //     badge: null,
  //     description:
  //         'Aromatic, freshly-cut coriander bunches. Essential herb for Asian and Middle Eastern cuisines. Supplied in 100 g bunches.',
  //     tags: ['Local Farm', 'Organic'],
  //     time: 'Min. 1 kg',
  //   ),
  // ];

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
    const Address(
      id: 1,
      label: 'Central Depot',
      address: '12 Market Way, Flemington, VIC 3031',
      icon: '🏭',
      type: 'Pickup',
    ),
    const Address(
      id: 2,
      label: 'City Restaurant',
      address: '88 Collins Street, Melbourne, VIC 3000',
      icon: '🍽️',
      type: 'Delivery',
    ),
    const Address(
      id: 3,
      label: 'Supermarket Hub',
      address: '240 Bourke Road, Hawthorn, VIC 3122',
      icon: '🏪',
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
