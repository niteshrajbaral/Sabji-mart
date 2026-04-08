import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/product.dart';
import '../../models/composite_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../providers/product_provider.dart';
import '../components/app_back_button.dart';
import '../../components/product_bottom_cta.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

class CompositeProductDetailScreen extends StatefulWidget {
  final Product product;

  const CompositeProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<CompositeProductDetailScreen> createState() =>
      _CompositeProductDetailScreenState();
}

class _CompositeProductDetailScreenState
    extends State<CompositeProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = context.read<CartProvider>();
      final cartItem = cartProvider
          .items
          .where((i) => i.product.id == widget.product.id)
          .firstOrNull;
      if (cartItem != null && mounted) {
        setState(() {
          _quantity = cartItem.quantity;
        });
      } else if (mounted) {
        // Auto-add product to cart with quantity 1 on opening
        setState(() {
          _quantity = 1;
        });
        cartProvider.addProduct(widget.product, quantity: 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favProv = context.watch<FavouritesProvider>();
    final isFav = favProv.isFavourite(widget.product.id);
    final totalPrice = widget.product.price * _quantity;

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
                        // Display product image with caching
                        if (widget.product.image.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: widget.product.image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white70,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.restaurant,
                              size: 100,
                              color: Colors.white70,
                            ),
                          )
                        else
                          const Icon(
                            Icons.restaurant,
                            size: 100,
                            color: Colors.white70,
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
                      // Name and Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Rs ${widget.product.price.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        widget.product.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                                height: 1.6),
                      ),
                      const SizedBox(height: 24),

                      // Composite Items Section
                      _SectionHeader(
                        title: l10n.includesItems,
                      ),
                      const SizedBox(height: 16),
                      
                      // List of composite items
                      ...widget.product.compositeItems.map((item) {
                        return _CompositeItemCard(
                          item: item,
                        );
                      }),
                      
                      if (widget.product.compositeItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            l10n.noItemsInBundle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      
                      const SizedBox(height: 24),

                      // Bundle Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.bundleInfo,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                              ),
                            ),
                          ],
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
                  SnackBar(content: Text(l10n.selectQuantityError)),
                );
              }
            },
            onQuantityChanged: (newQty) {
              setState(() => _quantity = newQty);
              final cart = context.read<CartProvider>();
              if (cart.contains(widget.product)) {
                cart.updateById(widget.product.id, newQty);
              } else {
                cart.addProduct(widget.product, quantity: newQty);
              }
            },
          ),
        ],
      ),
    );
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

class _CompositeItemCard extends StatelessWidget {
  final CompositeItem item;

  const _CompositeItemCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    // Find the product by matching compositeProduct ID
    final productProvider = context.watch<ProductProvider>();
    final product = productProvider.products.firstWhere(
      (p) => p.id == item.compositeProduct,
                              orElse: () => Product(
                                id: '',
                                name: item.name,
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

    final imageUrl = product.image;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Item image
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.eco,
                      color: Colors.white70,
                      size: 22,
                    ),
                  )
                : const Icon(
                    Icons.eco,
                    color: Colors.white70,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          // Quantity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '× ${item.quantity.toString()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
