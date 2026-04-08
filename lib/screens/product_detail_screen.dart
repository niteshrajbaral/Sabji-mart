import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/product.dart';
import '../../models/addon.dart';
import '../../models/variant.dart';
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
  int _quantity = 1;
  int _activeImage = 0;
  int _selectedVariantIndex = 0;
  // Track selected quantity for each addon by its index
  final Map<int, int> _selectedAddonQuantities = {};
  final TextEditingController _instructionsCtrl = TextEditingController();

  /// Get the selected variant item from the product's variants
  VariantItem? get _selectedVariantItem {
    if (widget.product.variants.isEmpty) return null;
    final variant = widget.product.variants.first;
    if (_selectedVariantIndex >= variant.variantItems.length) return null;
    return variant.variantItems[_selectedVariantIndex];
  }

  /// Get the formatted display name for a variant item
  String _getVariantDisplayName(VariantItem item) {
    if (widget.product.variants.isEmpty) return '';
    final variant = widget.product.variants.first;
    final optionTitles = variant.options.map((o) => o.title).toList();
    
    List<String> parts = [];
    for (int i = 0; i < item.optionValues.length; i++) {
      if (i < optionTitles.length) {
        parts.add('${optionTitles[i]}: ${item.optionValues[i]}');
      } else {
        parts.add(item.optionValues[i]);
      }
    }
    return parts.join(' | ');
  }

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
          // Restore addon selections from cart item
          _selectedAddonQuantities.addAll(cartItem.selectedAddonQuantities);
          // Restore variant selection if exists
          if (cartItem.variantPrice != null && widget.product.variants.isNotEmpty) {
            // Find the variant index that matches the stored variant price
            final variantItems = widget.product.variants.first.variantItems;
            final variantIndex = variantItems.indexWhere((v) => v.price == cartItem.variantPrice);
            if (variantIndex >= 0) {
              _selectedVariantIndex = variantIndex;
            }
          }
        });
      } else if (mounted) {
        // Auto-add product to cart with quantity 1 on opening
        setState(() {
          _quantity = 1;
        });
        // Pass variant price, name, and addon selections if available
        final variantItem = _selectedVariantItem;
        cartProvider.addProduct(
          widget.product,
          quantity: 1,
          variantPrice: variantItem?.price,
          variantName: variantItem != null ? _getVariantDisplayName(variantItem) : null,
        );
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

    // Use variant price if available, otherwise use product base price
    final variantPrice = _selectedVariantItem?.price ?? widget.product.price;
    
    // Calculate addons price from selected addon quantities
    double addonsPrice = 0.0;
    _selectedAddonQuantities.forEach((addonIndex, quantity) {
      if (quantity > 0 && addonIndex < widget.product.addons.length) {
        addonsPrice += widget.product.addons[addonIndex].price * quantity;
      }
    });

    final double totalPrice =
        (variantPrice + addonsPrice) * _quantity;

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

                      // Variants Section
                      if (widget.product.variants.isNotEmpty &&
                          widget.product.variants.first.variantItems.isNotEmpty) ...[
                        _SectionHeader(
                          title: widget.product.variants.first.options.isNotEmpty
                              ? widget.product.variants.first.options.first.title
                              : l10n.variants,
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(
                          widget.product.variants.first.variantItems.length,
                          (i) {
                            final variantItem =
                                widget.product.variants.first.variantItems[i];
                            return _VariantItem(
                              name: _getVariantDisplayName(variantItem),
                              price: variantItem.price,
                              isActive: _selectedVariantIndex == i,
                              isAvailable: variantItem.isAvailable,
                              onTap: () => setState(() => _selectedVariantIndex = i),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      const SizedBox(height: 24),

                      // Add-ons
                      if (widget.product.addons.isNotEmpty) ...[
                        _SectionHeader(
                          title: l10n.addOns,
                        ),
                        const SizedBox(height: 16),
                        ...widget.product.addons.asMap().entries.map((entry) {
                          final addonIndex = entry.key;
                          final addon = entry.value;
                          final selectedQty = _selectedAddonQuantities[addonIndex] ?? 0;
                          return _AddonItem(
                            addon: addon,
                            selectedQuantity: selectedQty,
                            onIncrement: () {
                              if (selectedQty < addon.maxAvailable) {
                                setState(() {
                                  _selectedAddonQuantities[addonIndex] = selectedQty + 1;
                                });
                                // Sync addon changes to cart if product exists
                                final cart = context.read<CartProvider>();
                                if (cart.contains(widget.product)) {
                                  final cartItem = cart.items.firstWhere((i) => i.product.id == widget.product.id);
                                  cartItem.selectedAddonQuantities = Map<int, int>.from(_selectedAddonQuantities);
                                  cartItem.variantPrice = _selectedVariantItem?.price;
                                  cartItem.variantName = _selectedVariantItem != null ? _getVariantDisplayName(_selectedVariantItem!) : null;
                                }
                              }
                            },
                            onDecrement: () {
                              if (selectedQty > 0) {
                                setState(() {
                                  _selectedAddonQuantities[addonIndex] = selectedQty - 1;
                                });
                                // Sync addon changes to cart if product exists
                                final cart = context.read<CartProvider>();
                                if (cart.contains(widget.product)) {
                                  final cartItem = cart.items.firstWhere((i) => i.product.id == widget.product.id);
                                  cartItem.selectedAddonQuantities = Map<int, int>.from(_selectedAddonQuantities);
                                  cartItem.variantPrice = _selectedVariantItem?.price;
                                  cartItem.variantName = _selectedVariantItem != null ? _getVariantDisplayName(_selectedVariantItem!) : null;
                                }
                              }
                            },
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
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
                // Pass variant price, name, and addon selections if available
                final variantItem = _selectedVariantItem;
                cart.addProduct(
                  widget.product,
                  quantity: _quantity,
                  variantPrice: variantItem?.price,
                  variantName: variantItem != null ? _getVariantDisplayName(variantItem) : null,
                  selectedAddonQuantities: Map<int, int>.from(_selectedAddonQuantities),
                );
              }
            },
            onCheckout: () {
              if (_quantity > 0) {
                final cart = context.read<CartProvider>();
                if (!cart.contains(widget.product)) {
                  // Pass variant price, name, and addon selections if available
                  final variantItem = _selectedVariantItem;
                  cart.addProduct(
                    widget.product,
                    quantity: _quantity,
                    variantPrice: variantItem?.price,
                    variantName: variantItem != null ? _getVariantDisplayName(variantItem) : null,
                    selectedAddonQuantities: Map<int, int>.from(_selectedAddonQuantities),
                  );
                }
                context.push('/cart');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(l10n.selectQuantityError)),
                );
              }
            },
            onQuantityChanged: (newQty) {
              setState(() => _quantity = newQty);
              final cart = context.read<CartProvider>();
              if (cart.contains(widget.product)) {
                cart.updateById(widget.product.id, newQty);
              } else {
                // Pass variant price, name, and addon selections if available
                final variantItem = _selectedVariantItem;
                cart.addProduct(
                  widget.product,
                  quantity: newQty,
                  variantPrice: variantItem?.price,
                  variantName: variantItem != null ? _getVariantDisplayName(variantItem) : null,
                  selectedAddonQuantities: Map<int, int>.from(_selectedAddonQuantities),
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

class _VariantItem extends StatelessWidget {
  final String name;
  final double price;
  final bool isActive;
  final bool isAvailable;
  final VoidCallback onTap;

  const _VariantItem({
    required this.name,
    required this.price,
    required this.isActive,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isAvailable
              ? Theme.of(context).cardColor
              : Theme.of(context).cardColor.withValues(alpha: 0.5),
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
                  color: !isAvailable
                      ? Theme.of(context).dividerColor
                      : isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).unselectedWidgetColor,
                  width: !isAvailable ? 1.5 : isActive ? 6 : 1.5,
                ),
                color: !isAvailable
                    ? Theme.of(context).dividerColor.withValues(alpha: 0.3)
                    : null,
              ),
              child: !isAvailable
                  ? Icon(Icons.close, size: 14,
                      color: Theme.of(context).cardColor)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      decoration: isAvailable ? null : TextDecoration.lineThrough,
                    ),
              ),
            ),
            Text(
              'Rs ${price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: !isAvailable
                        ? Theme.of(context).dividerColor
                        : isActive
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

class _AddonItem extends StatelessWidget {
  final Addon addon;
  final int selectedQuantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _AddonItem({
    required this.addon,
    required this.selectedQuantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selectedQuantity > 0
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: selectedQuantity > 0 ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addon.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (addon.description.isNotEmpty)
                  Text(
                    addon.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Text(
                  'Rs ${addon.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: selectedQuantity > 0 ? onDecrement : null,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: selectedQuantity > 0
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 24,
                  child: Text(
                    '$selectedQuantity',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                  ),
                ),
                GestureDetector(
                  onTap: selectedQuantity < addon.maxAvailable ? onIncrement : null,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: selectedQuantity < addon.maxAvailable
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              price == 0 ? AppLocalizations.of(context)!.free : '+ Rs ${price.toStringAsFixed(0)}',
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
