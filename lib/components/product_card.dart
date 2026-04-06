import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text_styles.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

/// List-view product card with live qty counter on the add button.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;
  final bool isFavourite;
  final VoidCallback onToggleFavourite;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onQuickAdd,
    required this.isFavourite,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final cartData = context.select<CartProvider, (int, double?)>((cart) {
      final items = cart.items.where((i) => i.product.id == product.id).toList();
      final qty = items.fold(0, (sum, i) => sum + i.quantity);
      // Get the variant price from the first matching cart item (if any)
      final variantPrice = items.isNotEmpty ? items.first.variantPrice : null;
      return (qty, variantPrice);
    });
    final qty = cartData.$1;
    final variantPrice = cartData.$2;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Emoji image
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppDecorations.radiusM)),
                    clipBehavior: Clip.hardEdge,
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDecorations.radiusM),
                      child: Image.network(product.image, fit: BoxFit.fill, height: 90,)
                    )
                  ),
                  const SizedBox(width: 16),
                  // Text column — no button here
                  Expanded(
                    child: SizedBox(
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Name + favourite
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.darkBrown,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: onToggleFavourite,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isFavourite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFavourite
                                        ? AppColors.terracotta
                                        : AppColors.softBrown,
                                    size: 16,
                                    key: ValueKey(isFavourite),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Price only — button is Positioned separately
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Rs ${(variantPrice ?? product.price).toStringAsFixed(0)}',
                                style: AppTextStyles.price,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── AddCounter pinned to the bottom-right corner ──────────────
            Positioned(
              right: 14,
              bottom: 14,
              child: AddCounter(
                qty: qty,
                productId: product.id,
                onAdd: onQuickAdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Compact "+" that expands to "−  N  +" once qty > 0.
class AddCounter extends StatelessWidget {
  final int qty;
  final String productId;
  final VoidCallback onAdd;

  const AddCounter({
    super.key,
    required this.qty,
    required this.productId,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = qty > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      height: 32,
      width: hasItems ? 88 : 32,
      decoration: BoxDecoration(
        color: AppColors.darkBrown,
        borderRadius: BorderRadius.circular(AppDecorations.radiusSM),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334A3728), // primary with 20% opacity
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: hasItems
          ? Row(
              children: [
                // − decrement
                Expanded(
                  child: GestureDetector(
                    onTap: () => context
                        .read<CartProvider>()
                        .updateById(productId, qty - 1),
                    child: Icon(Icons.remove_rounded,
                        color: AppColors.cream, size: 14),
                  ),
                ),
                // Animated count
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Text(
                    '$qty',
                    key: ValueKey(qty),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.cream,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                // + increment
                Expanded(
                  child: GestureDetector(
                    onTap: onAdd,
                    child: Icon(Icons.add_rounded,
                        color: AppColors.cream, size: 14),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: onAdd,
              child: const Icon(Icons.add_rounded,
                  color: AppColors.cream, size: 18),
            ),
    );
  }
}
