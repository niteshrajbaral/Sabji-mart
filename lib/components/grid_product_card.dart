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
    final isWide = width > 800;
    final cartData = context.select<CartProvider, (int, double?)>((cart) {
      final items =
          cart.items.where((i) => i.product.id == product.id).toList();
      final qty = items.fold(0, (sum, i) => sum + i.quantity);
      final variantPrice = items.isNotEmpty ? items.first.variantPrice : null;
      return (qty, variantPrice);
    });
    final qty = cartData.$1;
    final displayPrice = cartData.$2 ?? product.defaultDisplayPrice;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            AspectRatio(
              aspectRatio: 1.2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppDecorations.radiusM)),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  // Variant badge (top-left) — compact indicator that frees
                  // vertical space in the info area.
                  if (product.variants.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          borderRadius:
                              BorderRadius.circular(AppDecorations.radiusXS),
                        ),
                        child: Text(
                          '${product.variants.first.variantItems.length} opts',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.darkBrown,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onToggleFavourite,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.85),
                            borderRadius:
                                BorderRadius.circular(AppDecorations.radiusXS),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isFavourite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavourite
                                ? AppColors.terracotta
                                : const Color(0xFF2D7A55),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info — name on top, price + counter anchored at bottom
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkBrown,
                        fontWeight: FontWeight.w500,
                        fontSize: isWide ? 13 : 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    // const Spacer(),
                    Expanded(
                      child: Text(
                        'Rs ${displayPrice.toStringAsFixed(0)}',
                        style: AppTextStyles.price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // const SizedBox(width: 6),
                    Align(
                        alignment: AlignmentGeometry.bottomEnd,
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(left: 0),
                          child: _GridAddCounter(
                            qty: qty,
                            productId: product.id,
                            onAdd: onQuickAdd,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Compact "+" that expands to "−  N  +" once qty > 0 (grid variant).
class _GridAddCounter extends StatefulWidget {
  final int qty;
  final String productId;
  final VoidCallback onAdd;

  const _GridAddCounter({
    super.key,
    required this.qty,
    required this.productId,
    required this.onAdd,
  });

  @override
  State<_GridAddCounter> createState() => _GridAddCounterState();
}

class _GridAddCounterState extends State<_GridAddCounter> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _submitQuantity();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    _controller.text = widget.qty.toString();
    _focusNode.requestFocus();
  }

  void _submitQuantity() {
    final text = _controller.text.trim();
    int? newQty = int.tryParse(text);

    // Validate: must be a number between 1 and 99
    if (newQty == null || newQty < 1) {
      newQty = widget.qty; // Revert to current quantity
    } else if (newQty > 99) {
      newQty = 99; // Cap at 99
    }

    if (newQty != widget.qty) {
      context.read<CartProvider>().updateById(widget.productId, newQty);
    }

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.qty > 0;
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      height: 28,
      width: hasItems ? 88 : 28,
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDecorations.radiusXS),
      ),
      clipBehavior: Clip.hardEdge,
      child: hasItems
          ? Row(
              children: [
                // − decrement
                GestureDetector(
                    onTap: () => context
                        .read<CartProvider>()
                        .updateById(widget.productId, widget.qty - 1),
                    child: AnimatedContainer(
                      width: 28,
                      height: 28,
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppDecorations.radiusXS),
                        color: AppColors.cream,
                      ),
                      child: Icon(Icons.remove_rounded,
                          color: AppColors.darkBrown, size: 22),
                    )),

                // Animated count or TextField
                SizedBox(
                  width: 28,
                  child: GestureDetector(
                    onTap: _startEditing,
                    child: _isEditing
                        ? Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 28,
                              child: Align(
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  cursorColor: AppColors.black,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    height: 2.1,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _submitQuantity(),
                                  autofocus: true,
                                ),
                              ),
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Text(
                              '${widget.qty}',
                              key: ValueKey(widget.qty),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                  ),
                ),
                // + increment
                GestureDetector(
                    onTap: widget.onAdd,
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppDecorations.radiusXS),
                            color: AppColors.darkBrown),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.cream,
                          size: 22,
                        ))),
              ],
            )
          : GestureDetector(
              onTap: widget.onAdd,
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDecorations.radiusXS),
                      color: AppColors.darkBrown),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.cream,
                    size: 22,
                  ))),
    );
  }
}
