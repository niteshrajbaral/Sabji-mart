import '../../theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../l10n/app_localizations.dart';
import '../../config/api_config.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/orders_provider.dart';
import '../../components/address_selector.dart';
import '../../components/category_pill.dart';
import '../../components/product_card.dart';
import '../../components/grid_product_card.dart';
import '../../components/reorder_card.dart';
import '../../components/offer_slider.dart';
import '../../components/section_header.dart';
import '../../providers/nav_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String _sortBy = 'default';
  bool _gridView = false;
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    // Load products on screen initialization, plus recent orders when logged in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<OrdersProvider>().fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _quickAdd(Product product) {
    if (product.variants.isNotEmpty &&
        product.variants.first.variantItems.isNotEmpty) {
      // Select first available variant item by default for products with variants
      final firstVariantItem = product.variants.first.variantItems.firstWhere(
        (item) => item.isAvailable,
        orElse: () => product.variants.first.variantItems.first,
      );
      // Create variant name by joining option values
      final variantName = firstVariantItem.optionValues.join(' / ');
      context.read<CartProvider>().addProduct(
            product,
            variantPrice: firstVariantItem.price,
            variantName: variantName,
          );
    } else {
      context.read<CartProvider>().addProduct(product);
    }
  }

  void _showAddressSheet() {
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

  // Responsive grid breakpoints. Picks column count + aspect ratio per width.
  SliverGridDelegate _gridDelegateFor(double width) {
    final int crossAxisCount;
    final double childAspectRatio;
    if (width >= 1400) {
      crossAxisCount = 6;
      childAspectRatio = 0.82;
    } else if (width >= 1100) {
      crossAxisCount = 5;
      childAspectRatio = 0.82;
    } else if (width >= 800) {
      crossAxisCount = 4;
      childAspectRatio = 0.78;
    } else if (width >= 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.76;
    } else if (width >= 400) {
      crossAxisCount = 2;
      childAspectRatio = 0.74;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.66;
    }
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
    );
  }

  List<Product> get _filtered {
    final productProv = context.watch<ProductProvider>();
    final products = productProv.products;

    List<Product> list = _selectedCategory == 'all'
        ? List.of(products)
        : products.where((p) => p.category == _selectedCategory).toList();

    // Filter out composite items (they are shown in the offer slider)
    // Only filter when not searching, so users can still find composite items via search
    if (_searchQuery.trim().isEmpty) {
      list = list.where((p) => !p.usesCompositeItems).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    switch (_sortBy) {
      case 'price_low':
        list.sort((a, b) =>
            a.defaultDisplayPrice.compareTo(b.defaultDisplayPrice));
        break;
      case 'price_high':
        list.sort((a, b) =>
            b.defaultDisplayPrice.compareTo(a.defaultDisplayPrice));
        break;
    }
    return list;
  }

  // case 'rating':
  //   list.sort((a, b) => b.rating.compareTo(a.rating));
  //   break;
  // case 'popular':
  //   list.sort((a, b) => b.reviews.compareTo(a.reviews));
  //   break;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favProv = context.watch<FavouritesProvider>();
    final addrProv = context.watch<AddressProvider>();
    final width = MediaQuery.of(context).size.width;
    final filtered = _filtered;
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    final allOrders = context.watch<OrdersProvider>().orders;
    // Only show orders belonging to this app's configured business.
    final recentOrders = allOrders
        .where((o) => o.businessId == ApiConfig.businessId)
        .toList();
    final bool showRecent = _searchQuery.isEmpty &&
        _selectedCategory == 'all' &&
        isAuthenticated &&
        recentOrders.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: AddressSelector(
                      selectedId: addrProv.selectedId,
                      onTap: _showAddressSheet,
                      variant: AddressSelectorVariant.header,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Notification bell
                  IconButton(
                    onPressed: () => context.push('/profile/notifications'),
                    style: IconButton.styleFrom(
                      backgroundColor: Color.fromARGB(1, 0, 0, 0),
                      foregroundColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      minimumSize: const Size(44, 44),
                    ),
                    icon: const Icon(Icons.notifications_outlined, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Search ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _SearchBar(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                onClear: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
              ),
            ),
            const SizedBox(height: 8),

            // ── Category Pills ───────────────────────────────────────
            SizedBox(
              height: 42,
              child: Consumer<CategoryProvider>(
                builder: (context, categoryProv, _) {
                  final categories = categoryProv.categories;
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    children: [
                      CategoryPill(
                        label: 'All',
                        // color: const Color(0xFF000000 + c.color),
                        active: _selectedCategory == 'all',
                        onTap: () {
                          setState(() => _selectedCategory = 'all');
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut);
                          }
                          context.read<NavProvider>().triggerCategoryChange();
                        },
                      ),
                      const SizedBox(width: 10),
                      ...categories.map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CategoryPill(
                            label: c.name,
                            // color: const Color(0xFF000000 + c.color),
                            active: _selectedCategory == c.id,
                            onTap: () {
                              setState(() => _selectedCategory = c.id);
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut);
                              }
                              context.read<NavProvider>().triggerCategoryChange();
                            },
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── Scrollable content (sliver-based for lazy product list) ──
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Top fixed-list section (offers, recent orders, section header)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        width > 400 ? 24 : 16, 0, width > 400 ? 24 : 16, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        const OfferSlider(),
                        const SizedBox(height: 20),
                        if (showRecent) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.recentOrders,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontSize: 18)),
                              const _ViewAllButton(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 155,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: recentOrders.length.clamp(0, 3),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (_, i) {
                                final order = recentOrders[i];
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () =>
                                        context.push('/home/recent_orders'),
                                    child: SizedBox(
                                      width: 200,
                                      child: OrderCard(
                                        order: order,
                                        featured: i == 0,
                                        onReorder: () {
                                          final products = context
                                              .read<ProductProvider>()
                                              .products;
                                          final result = context
                                              .read<CartProvider>()
                                              .reorder(order, products);
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          if (result.added == 0) {
                                            messenger.showSnackBar(const SnackBar(
                                              content: Text(
                                                  'None of these items are available right now.'),
                                            ));
                                            return;
                                          }
                                          final skipped = result.unavailable +
                                              result.missing;
                                          if (skipped > 0) {
                                            messenger.showSnackBar(SnackBar(
                                              content: Text(
                                                  'Added ${result.added} item${result.added == 1 ? '' : 's'}; $skipped unavailable.'),
                                            ));
                                          }
                                          context.push('/cart');
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              '${filtered.length} ${filtered.length == 1 ? l10n.result : l10n.results}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        SectionHeader(
                          title: l10n.todaysHarvest,
                          trailing: Row(
                            children: [
                              _SortButton(
                                sortBy: _sortBy,
                                onChanged: (v) =>
                                    setState(() => _sortBy = v),
                              ),
                              const SizedBox(width: 6),
                              _ViewToggle(
                                isGrid: _gridView,
                                onToggle: (v) =>
                                    setState(() => _gridView = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ]),
                    ),
                  ),

                  // Products — lazily rendered
                  if (filtered.isEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width > 400 ? 24 : 16),
                      sliver: SliverToBoxAdapter(
                        child: _EmptyState(
                          onClear: () => setState(() {
                            _searchQuery = '';
                            _searchCtrl.clear();
                            _sortBy = 'default';
                            _selectedCategory = 'all';
                          }),
                        ),
                      ),
                    )
                  else if (_gridView)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width > 400 ? 24 : 16),
                      sliver: SliverGrid.builder(
                        gridDelegate: _gridDelegateFor(width),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final p = filtered[i];
                          return GridProductCard(
                            product: p,
                            onTap: () =>
                                context.push('/home/product', extra: p),
                            onQuickAdd: () => _quickAdd(p),
                            isFavourite: favProv.isFavourite(p.id),
                            onToggleFavourite: () => favProv.toggle(p.id),
                          );
                        },
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width > 400 ? 24 : 16),
                      sliver: SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (_, i) {
                          final p = filtered[i];
                          return ProductCard(
                            product: p,
                            onTap: () =>
                                context.push('/home/product', extra: p),
                            onQuickAdd: () => _quickAdd(p),
                            isFavourite: favProv.isFavourite(p.id),
                            onToggleFavourite: () => favProv.toggle(p.id),
                          );
                        },
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewAllButton extends StatefulWidget {
  const _ViewAllButton();

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.push('/home/recent_orders'),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: _isHovered
                  ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8)
                  : Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.w500,
              fontSize: 13),
          child: Text(l10n.viewAll),
        ),
      ),
    );
  }
}

// ── Private helper widgets ────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: l10n.searchHint,
        prefixIcon: Icon(Icons.search_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                onPressed: onClear,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.transparent,
                  shadowColor: AppColors.transparent,
                ),
                icon: Icon(Icons.close_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16
                    ),
              )
            : null,
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String sortBy;
  final ValueChanged<String> onChanged;

  const _SortButton({required this.sortBy, required this.onChanged});

  List<({String id, String label})> _getOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      (id: 'default', label: l10n.defaultSort),
      (id: 'price_low', label: l10n.priceLowHigh),
      (id: 'price_high', label: l10n.priceHighLow),
      (id: 'rating', label: l10n.topRated),
      (id: 'popular', label: l10n.mostPopular),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isActive = sortBy != 'default';
    final l10n = AppLocalizations.of(context)!;
    final options = _getOptions(context);

    return TextButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.sortBy,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    ...options.map((opt) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            onChanged(opt.id);
                            Navigator.pop(context);
                          },
                          title: Text(opt.label,
                              style: Theme.of(context).textTheme.bodyLarge),
                          trailing: sortBy == opt.id
                              ? Icon(Icons.check_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer)
                              : null,
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      statesController:
          WidgetStatesController({if (isActive) WidgetState.selected}),
      style: TextButton.styleFrom(
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: const Icon(Icons.sort_rounded, size: 20),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onToggle;

  const _ViewToggle({required this.isGrid, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        minimumSize: const Size(30, 30),
        padding: const EdgeInsets.symmetric(horizontal: 1),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      segments: const [
        ButtonSegment(value: false, icon: Icon(Icons.view_list_rounded)),
        ButtonSegment(value: true, icon: Icon(Icons.grid_view_rounded)),
      ],
      selected: {isGrid},
      onSelectionChanged: (set) => onToggle(set.first),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Flexible(
            child: Lottie.asset('assets/animations/empty_search.json',
                width: 200, repeat: false, fit: BoxFit.contain),
          ),
          const SizedBox(height: 14),
          Text(l10n.noItemsFound,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(l10n.adjustSearch,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onClear,
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );
  }
}
