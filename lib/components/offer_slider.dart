import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class OfferSlider extends StatefulWidget {
  const OfferSlider({super.key});

  @override
  State<OfferSlider> createState() => _OfferSliderState();
}

class _OfferSliderState extends State<OfferSlider> {
  final PageController _pageController = PageController();
  
  int _currentPage = 0;
  Timer? _timer;

  List<Map<String, String>> _offers = [];

  @override
  void initState() {
    super.initState();
    // Load products if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      if (productProvider.products.isEmpty && !productProvider.isLoading) {
        productProvider.loadProducts();
      }
    });
  }

  void _buildOffers(List<Product> products) {
    debugPrint('[OfferSlider] Building offers from ${products.length} products');
    
    // Filter products with usesCompositeItems: true
    final compositeProducts = products
        .where((p) => p.usesCompositeItems)
        .toList();

    debugPrint('[OfferSlider] Found ${compositeProducts.length} composite products');
    
    for (var p in compositeProducts) {
      debugPrint('[OfferSlider]   - ${p.name}: usesCompositeItems=${p.usesCompositeItems}');
    }

    // Convert products to offer format
    _offers = compositeProducts.map((product) {
      // Generate a consistent color based on product ID
      final color = _generateColor(product.id);
      
      return {
        'title': product.name,
        'subtitle': product.description.isNotEmpty 
            ? product.description 
            : 'New offer package in ${product.name}',
        'image': product.image,
        'color': color,
        // 'promo': 'COMPOSITE',
      };
    }).toList();

    debugPrint('[OfferSlider] Created ${_offers.length} offers');

    // Restart timer if we have offers
    _timer?.cancel();
    if (_offers.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_currentPage < _offers.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  String _generateColor(String id) {
    // Generate consistent colors from product ID
    final colors = [
      '#88B07A', // Fresh green
      '#4A6741', // Forest green
      '#D4A373', // Warm brown
      '#6B8E7E', // Sage green
      '#A8C69F', // Light green
      '#7B9E8C', // Muted green
      '#C4A882', // Tan
      '#5B8A72', // Teal green
    ];
    
    // Use hash of ID to pick a consistent color
    final hash = id.hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Build offers whenever products change
        if (productProvider.products.isNotEmpty) {
          _buildOffers(productProvider.products);
        }

        // If still loading or no offers, show loading or empty state
        if (productProvider.isLoading && _offers.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (_offers.isEmpty) {
          debugPrint('[OfferSlider] No offers to display');
          return const SizedBox.shrink();
        }

        debugPrint('[OfferSlider] Displaying ${_offers.length} offers');

        return Column(
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _offers.length,
                itemBuilder: (context, index) {
                  final offer = _offers[index];
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                      }
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _parseColor(offer['color']!),
                              _parseColor(offer['color']!).withValues(alpha: 0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _parseColor(offer['color']!)
                                  .withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Find the product that matches this offer
                              final productProvider = context.read<ProductProvider>();
                              final product = productProvider.products.firstWhere(
                                (p) => p.usesCompositeItems && p.name == offer['title'],
                                orElse: () => Product(
                                  id: '',
                                  name: '',
                                  category: '',
                                  price: 0,
                                  costPrice: 0,
                                  isVeg: false,
                                  isAvailable: false,
                                  usesOfferPrice: false,
                                  addons: [],
                                  adminId: '',
                                  compositeItems: [],
                                  variants: [],
                                  addedBy: '',
                                  isTaxable: false,
                                  orderedCount: 0,
                                  showInOrdering: false,
                                  sku: '',
                                  soldBy: '',
                                  image: '',
                                  description: '',
                                  tags: [],
                                  usesStocks: false,
                                  usesCompositeItems: false,
                                ),
                              );
                              if (product.id.isNotEmpty) {
                                context.push('/home/composite-product', extra: product);
                              }
                            },
                            borderRadius: BorderRadius.circular(28),
                            splashColor: Colors.white.withValues(alpha: 0.3),
                            highlightColor: Colors.white.withValues(alpha: 0.1),
                            child: Stack(
                              children: [
                                // Decorative Background Shapes
                                Positioned(
                                  right: -20,
                                  top: -20,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            Text(
                                              offer['title']!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              offer['subtitle']!,
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.9),
                                                fontSize: 13,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: offer['image']!.isNotEmpty
                                              ? ClipOval(
                                                  child: Image.network(
                                                    offer['image']!,
                                                    width: width>800?90:70,
                                                    height: width>800?90:70,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return const Icon(Icons.image, size: 70, color: Colors.white70);
                                                    },
                                                  ),
                                                )
                                              : const Icon(Icons.image, size: 70, color: Colors.white70),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _offers.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _currentPage == index
                        ? AppColors.darkBrown
                        : AppColors.darkBrown.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  }
}