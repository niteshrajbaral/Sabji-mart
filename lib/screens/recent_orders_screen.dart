import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_data.dart';
import '../../components/reorder_card.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../components/app_back_button.dart';
import 'package:go_router/go_router.dart';

class RecentOrdersScreen extends StatefulWidget {
  const RecentOrdersScreen({super.key});

  @override
  State<RecentOrdersScreen> createState() => _RecentOrdersScreenState();
}

class _RecentOrdersScreenState extends State<RecentOrdersScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageCtrl;
  late Animation<double> _pageFade;
  late Animation<Offset> _pageSlide;

  final List<AnimationController> _cardCtrls = [];

  @override
  void initState() {
    super.initState();

    _pageCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pageFade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut));

    final orders = AppData.recentOrders;
    for (var i = 0; i < orders.length; i++) {
      final ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 400));
      _cardCtrls.add(ctrl);
    }

    // Stagger card animations exactly like JSX (0.15 + i * 0.1s delay)
    Future.microtask(() async {
      _pageCtrl.forward();
      for (var i = 0; i < _cardCtrls.length; i++) {
        await Future.delayed(Duration(milliseconds: 150 + i * 100));
        if (mounted) _cardCtrls[i].forward();
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = AppData.recentOrders;
    final totalSpent = orders.fold<double>(0, (sum, o) => sum + o.total);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: AppBackButton(),
        ),
        title: const Text('Recent Orders'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Scrollable body ──────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _pageFade,
                child: SlideTransition(
                  position: _pageSlide,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    children: [
                      // ── This Month summary card ──────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.onSurfaceVariant
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('THIS MONTH',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      letterSpacing: 1.5,
                                      fontSize: 11,
                                    )),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${orders.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 32,
                                          ),
                                    ),
                                    Text(
                                      'orders placed',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context).colorScheme.onPrimary
                                                .withValues(alpha: 0.5),
                                            fontSize: 13,
                                          ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rs ${totalSpent.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 24,
                                          ),
                                    ),
                                    Text(
                                      'total spent',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context).colorScheme.onPrimary
                                                .withValues(alpha: 0.5),
                                            fontSize: 13,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Order cards ──────────────────────────────
                      ...orders.asMap().entries.map((entry) {
                        final i = entry.key;
                        final order = entry.value;
                        final ctrl = _cardCtrls[i];
                        return FadeTransition(
                          opacity: CurvedAnimation(
                              parent: ctrl, curve: Curves.easeOut),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                                parent: ctrl, curve: Curves.easeOut)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OrderCard(
                                order: order,
                                featured: false,
                                onReorder: () {
                                  final products = context.read<ProductProvider>().products;
                                  context.read<CartProvider>().reorder(order, products);
                                  context.push('/cart');
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
