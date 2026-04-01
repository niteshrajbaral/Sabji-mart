import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../providers/product_provider.dart';
import '../components/app_back_button.dart';
import '../../components/product_bottom_cta.dart';

import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 0;
  int _activeImage = 0;
  int _selectedSideCard = 0;
  final Set<int> _selectedAddons = {};
  final TextEditingController _instructionsCtrl = TextEditingController();

  static const _mockSides = [
    (name: 'French Fries', price: 0.0),
    (name: 'Garden Salad', price: 2.0),
    (name: 'Grilled Asparagus', price: 4.0),
  ];

  static const _mockAddons = [
    (name: 'Extra Cheese', price: 1.50),
    (name: 'Crispy Bacon', price: 3.00),
    (name: 'Fried Egg', price: 2.00),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartItem = context
          .read<CartProvider>()
          .items
          .where((i) => i.product.id == widget.product.id)
          .firstOrNull;
      if (cartItem != null && mounted) {
        setState(() {
          _quantity = cartItem.quantity;
        });
      }
    });
  }

  @override
  void dispose() {
    _instructionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favProv = context.watch<FavouritesProvider>();
    final productProv = context.watch<ProductProvider>();
    final isFav = favProv.isFavourite(widget.product.id);

    final double sidesPrice =
        _mockSides.isNotEmpty ? _mockSides[_selectedSideCard].price : 0.0;

    final double addonsPrice = _selectedAddons
        .map((i) => _mockAddons[i].price)
        .fold(0.0, (sum, price) => sum + price);

    final double totalPrice =
        (widget.product.price + sidesPrice + addonsPrice) * _quantity;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero Image ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: AppBackButton(),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => favProv.toggle(widget.product.id),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 40,
                      alignment: Alignment.center,
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.share_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: Theme.of(context)
                          .extension<AppThemeExtension>()
                          ?.heroGradient,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(widget.product.image,
                            style: const TextStyle(fontSize: 110)),
                        // Gallery dots
                        Positioned(
                          bottom: 18,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(3, (i) {
                              return GestureDetector(
                                onTap: () => setState(() => _activeImage = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  width: _activeImage == i ? 20 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: _activeImage == i
                                        ? Theme.of(context).colorScheme.surface
                                        : Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.product.name,
                              style: Theme.of(context).textTheme.displayMedium),
                          const SizedBox(height: 6),
                          // Text(widget.product.time,
                          //     style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(widget.product.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                  height: 1.6)),
                      const SizedBox(height: 18),

                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: widget.product.tags.map((tag) {
                          final isGood = tag.contains('Gluten') ||
                              tag.contains('Vegan') ||
                              tag.contains('Organic');
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: isGood
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .errorContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _localizeTag(tag, l10n),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: isGood
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer
                                        : Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                    fontSize: 12,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Choose your side
                      _SectionHeader(
                        title: l10n.variants,
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_mockSides.length, (i) {
                        return _OptionItem(
                          name: _mockSides[i].name,
                          price: _mockSides[i].price,
                          isActive: _selectedSideCard == i,
                          onTap: () => setState(() => _selectedSideCard = i),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Add-ons
                      _SectionHeader(
                        title: l10n.addOns,
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_mockAddons.length, (i) {
                        final isActive = _selectedAddons.contains(i);
                        return _OptionItem(
                          name: _mockAddons[i].name,
                          price: _mockAddons[i].price,
                          isActive: isActive,
                          onTap: () {
                            setState(() {
                              if (isActive) {
                                _selectedAddons.remove(i);
                              } else {
                                _selectedAddons.add(i);
                              }
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 24),

                      // Special Instructions
                      Text(
                        l10n.specialInstructions,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _instructionsCtrl,
                        maxLines: 4,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: l10n.specialInstructionsHint,
                          hintStyle:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                  ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          contentPadding: const EdgeInsets.all(20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                                color: Theme.of(context).dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                                color: Theme.of(context).dividerColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 120), // Padding for the floating action bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom CTA ───────────────────────────────────────────
          ProductBottomCta(
            quantity: _quantity,
            totalPrice: totalPrice,
            onDecrement: () {
              if (_quantity > 0) {
                setState(() => _quantity--);
                final cart = context.read<CartProvider>();
                if (cart.contains(widget.product)) {
                  cart.updateById(widget.product.id, _quantity);
                }
              }
            },
            onIncrement: () {
              setState(() => _quantity++);
              final cart = context.read<CartProvider>();
              if (cart.contains(widget.product)) {
                cart.updateById(widget.product.id, _quantity);
              } else {
                cart.addProduct(widget.product, quantity: _quantity);
              }
            },
            onCheckout: () {
              if (_quantity > 0) {
                final cart = context.read<CartProvider>();
                if (!cart.contains(widget.product)) {
                  cart.addProduct(widget.product, quantity: _quantity);
                }
                context.push('/cart');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(l10n.selectQuantityError)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _localizeTag(String tag, AppLocalizations l10n) {
    if (tag.contains('Organic')) return l10n.organicOnly;
    if (tag.contains('Seasonal')) return l10n.seasonal;
    if (tag.contains('Local Farm')) return l10n.localFarm;
    if (tag.contains('Premium')) return l10n.premiumGrade;
    if (tag.contains('Export')) return l10n.exportQuality;
    return tag;
  }
}

// ── Private Helper Widgets ───────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String name;
  final double price;
  final bool isActive;
  final VoidCallback onTap;

  const _OptionItem({
    required this.name,
    required this.price,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).unselectedWidgetColor,
                  width: isActive ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
            Text(
              price == 0 ? AppLocalizations.of(context)!.free : '+\$${price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
