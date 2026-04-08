import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../components/address_selector.dart';
import '../../components/primary_button.dart';
import '../../components/product_card.dart';
import '../../components/grid_product_card.dart';
import '../../providers/product_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../components/empty_cart_view.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _showAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (_) => AddressBottomSheet(
        selectedId: context.read<AddressProvider>().selectedId,
        onSelect: (id) => context.read<AddressProvider>().select(id),
        onAddNew: () {
          Navigator.pop(context);
          context.push('/profile/addresses/add');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cart = context.watch<CartProvider>();
    final addrProv = context.watch<AddressProvider>();
    final favProv = context.watch<FavouritesProvider>();
    final productProv = context.watch<ProductProvider>();

    final width = MediaQuery.of(context).size.width;

    final cartIds = cart.items.map((i) => i.product.id).toSet();
    final suggestions = productProv.products
        .where((p) => !cartIds.contains(p.id))
        .where((p) => !p.usesCompositeItems) // Filter out composite items (shown in offer slider)
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        title: Text(l10n.yourCart),
        actions: [
          if (cart.items.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Text(
                  '${cart.totalCount} ${cart.totalCount == 1 ? l10n.item : l10n.items}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: cart.items.isEmpty
                      ? const EmptyCartView()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
                          children: [
                            ...cart.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _CartItemCard(
                                  item: item,
                                  onTap: () => context.push('/home/product',
                                      extra: item.product),
                                  onQuickAdd: () =>
                                      cart.addProduct(item.product),
                                  isFavourite:
                                      favProv.isFavourite(item.product.id),
                                  onToggleFavourite: () =>
                                      favProv.toggle(item.product.id),
                                ),
                              );
                            }),

                            // Suggestions
                            if (suggestions.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(l10n.addExtra,
                                  style: AppTextStyles.headlineSmall),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: width> 800 ? 250 : 230,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  itemCount: suggestions.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (_, i) {
                                    final p = suggestions[i];
                                    return SizedBox(
                                      width: 160,
                                      child: GridProductCard(
                                        product: p,
                                        onTap: () => context
                                            .push('/home/product', extra: p),
                                        onQuickAdd: () => cart.addProduct(p),
                                        isFavourite: favProv.isFavourite(p.id),
                                        onToggleFavourite: () =>
                                            favProv.toggle(p.id),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Address
                            Text(l10n.deliverTo, style: AppTextStyles.labelSmall),
                            const SizedBox(height: 8),
                            AddressSelector(
                              selectedId: addrProv.selectedId,
                              onTap: () => _showAddressSheet(context),
                              variant: AddressSelectorVariant.compact,
                            ),
                            const SizedBox(height: 16),

                            // Price summary
                            Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow
                                  .withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDecorations.radiusCard),
                                side: BorderSide(
                                  color: AppColors.darkBrown
                                      .withValues(alpha: 0.05),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _PriceSummaryRow(
                                        label: l10n.subtotal,
                                        value: cart.subtotal),
                                    const SizedBox(height: 10),
                                    _PriceSummaryRow(
                                        label: l10n.deliveryFee, value: 130),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Divider(
                                          height: 1,
                                          color: AppColors.softBrown
                                              .withValues(alpha: 0.1)),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(l10n.total,
                                            style:
                                                AppTextStyles.headlineMedium),
                                        Text(
                                            'Rs ${cart.total.toStringAsFixed(0)}',
                                            style: AppTextStyles.priceLarge
                                                .copyWith(
                                              color: AppColors.terracotta,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),

            // Checkout button
            if (cart.items.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: PrimaryButton(
                  label: '${l10n.checkout} — Rs ${cart.total.toStringAsFixed(0)}',
                  onTap: () {
                    if (cart.items.isNotEmpty) {
                      context.push('/cart/checkout');
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PriceSummaryRow extends StatelessWidget {
  final String label;
  final double value;

  const _PriceSummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
        Text('Rs ${value.toStringAsFixed(0)}',
            style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600, color: AppColors.darkBrown)),
      ],
    );
  }
}

// ── Cart Item Card with Addon Details ────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;
  final bool isFavourite;
  final VoidCallback onToggleFavourite;

  const _CartItemCard({
    required this.item,
    required this.onTap,
    required this.onQuickAdd,
    required this.isFavourite,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity;

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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDecorations.radiusM),
                    ),
                    clipBehavior: Clip.hardEdge,
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDecorations.radiusM),
                      child: Image.network(item.product.image, fit: BoxFit.fill, height: 90),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + favourite
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.product.name,
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
                        // Variant name if selected
                        if (item.variantName != null && item.variantName!.isNotEmpty)
                          Text(
                            item.variantName!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                        // Addon details
                        if (item.selectedAddonQuantities.isNotEmpty &&
                            item.selectedAddonQuantities.values.any((q) => q > 0))
                          ...item.selectedAddonQuantities.entries.where((e) => e.value > 0).map((entry) {
                            final addonIndex = entry.key;
                            final addonQty = entry.value;
                            if (addonIndex < item.product.addons.length) {
                              final addon = item.product.addons[addonIndex];
                              return Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '• ${addon.name} x$addonQty (+Rs ${(addon.price * addonQty).toStringAsFixed(0)})',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.darkBrown,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        // Price
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Rs ${item.effectivePrice.toStringAsFixed(0)}',
                            style: AppTextStyles.price,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // AddCounter pinned to the bottom-right corner
            Positioned(
              right: 14,
              bottom: 14,
              child: AddCounter(
                qty: qty,
                productId: item.product.id,
                onAdd: onQuickAdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
