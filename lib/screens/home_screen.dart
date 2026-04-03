import '../../theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../data/app_data.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
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
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _quickAdd(Product product) {
    context.read<CartProvider>().addProduct(product);
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
          // navigate to add address handled by parent router
        },
      ),
    );
  }

  List<Product> get _filtered {
    final productProv = context.watch<ProductProvider>();
    final products = productProv.products;
    
    List<Product> list = _selectedCategory == 'all'
        ? List.of(products)
        : products
            .where((p) => p.category == _selectedCategory)
            .toList();

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
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        list.sort((a, b) => b.price.compareTo(a.price));
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
    final bool showRecent = _searchQuery.isEmpty && _selectedCategory == 'all';

    return FadeTransition(
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
                    backgroundColor: Theme.of(context).dividerColor,
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
            height: 60,
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

          // ── Scrollable content ───────────────────────────────────
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              children: [
                // ── Special Offers ───────────────────────────────────────
                const OfferSlider(),
                const SizedBox(height: 20),

                // Recent orders preview
                if (showRecent) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.recentOrders,
                          style: Theme.of(context).textTheme.headlineSmall),
                      GestureDetector(
                        onTap: () => context.push('/home/recent_orders'),
                        child: Text(l10n.viewAll,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: AppData.recentOrders.length.clamp(0, 3),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => context.push('/home/recent_orders'),
                        child: SizedBox(
                          width: 200,
                          child: OrderCard(
                            order: AppData.recentOrders[i],
                            featured: i == 0,
                            onReorder: () {
                              final products = context.read<ProductProvider>().products;
                              context
                                  .read<CartProvider>()
                                  .reorder(AppData.recentOrders[i], products);
                              context.push('/cart');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Search result info
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${filtered.length} ${filtered.length == 1 ? l10n.result : l10n.results}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),

                // Section title + Sort + View toggle
                SectionHeader(
                  title: l10n.todaysHarvest,
                  trailing: Row(
                    children: [
                      _SortButton(
                        sortBy: _sortBy,
                        onChanged: (v) => setState(() => _sortBy = v),
                      ),
                      const SizedBox(width: 6),
                      _ViewToggle(
                        isGrid: _gridView,
                        onToggle: (v) => setState(() => _gridView = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Empty state
                if (filtered.isEmpty)
                  _EmptyState(
                    onClear: () => setState(() {
                      _searchQuery = '';
                      _searchCtrl.clear();
                      _sortBy = 'default';
                      _selectedCategory = 'all';
                    }),
                  )
                else if (_gridView)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 800 ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: width>800? 1.6 : 0.8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      return GridProductCard(
                        product: p,
                        onTap: () => context.push('/home/product', extra: p),
                        onQuickAdd: () => _quickAdd(p),
                        isFavourite: favProv.isFavourite(p.id),
                        onToggleFavourite: () => favProv.toggle(p.id),
                      );
                    },
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      return ProductCard(
                        product: p,
                        onTap: () => context.push('/home/product', extra: p),
                        onQuickAdd: () => _quickAdd(p),
                        isFavourite: favProv.isFavourite(p.id),
                        onToggleFavourite: () => favProv.toggle(p.id),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
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
                icon: Icon(Icons.close_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 16),
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
          builder: (_) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
        );
      },
      statesController:
          WidgetStatesController({if (isActive) WidgetState.selected}),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
