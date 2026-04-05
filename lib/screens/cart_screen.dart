import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
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
                                child: ProductCard(
                                  product: item.product,
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
