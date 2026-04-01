
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text_styles.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

/// Grid-view product card with live qty counter on the add button.
class GridProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;
  final bool isFavourite;
  final VoidCallback onToggleFavourite;

  const GridProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onQuickAdd,
    required this.isFavourite,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final qty = context.select<CartProvider, int>((cart) => cart.items
        .where((i) => i.product.id == product.id)
        .fold(0, (sum, i) => sum + i.quantity));

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 150,
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Stack(
                children: [
                  Container(
                    height: width > 800 ? 150 : 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDecorations.radiusM),
                      color: const Color(0xFFC5DEA0),
                    ),
                    alignment: Alignment.center,
                    clipBehavior: Clip.hardEdge,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDecorations.radiusM),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        height: width > 800 ? 150 : 100,
                      ),
                    ),
                  ),
                  // Favourite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onToggleFavourite,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha:  0.85),
                          borderRadius: BorderRadius.circular(AppDecorations.radiusXS),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isFavourite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavourite
                              ? AppColors.terracotta
                              : const Color(0xFF2D7A55),
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Info + counter
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkBrown,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: AppTextStyles.price,
                            // overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
   
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 4),    
                         const Spacer(),
                        _GridAddCounter(
                          qty: qty,
                          productId: product.id,
                          onAdd: onQuickAdd,
                        ),
                  
                      ]
                    ),
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Compact "+" that expands to "−  N  +" once qty > 0 (grid variant).
class _GridAddCounter extends StatelessWidget {
  const _GridAddCounter({
    required this.qty,
    required this.productId,
    required this.onAdd,
  });

  final int qty;
  final String productId;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final bool hasItems = qty > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      height: 28,
      width: hasItems ? 80 : 28,
      decoration: BoxDecoration(
        color: AppColors.darkBrown,
        borderRadius: BorderRadius.circular(AppDecorations.radiusS),
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
                        color: AppColors.cream, size: 12),
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
                      fontSize: 12,
                    ),
                  ),
                ),
                // + increment
                Expanded(
                  child: GestureDetector(
                    onTap: onAdd,
                    child: Icon(Icons.add_rounded,
                        color: AppColors.cream, size: 12),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: onAdd,
              child: const Icon(Icons.add_rounded,
                  color: AppColors.cream, size: 16),
            ),
    );
  }
}