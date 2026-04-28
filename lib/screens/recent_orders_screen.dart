import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/orders_provider.dart';
import '../models/order.dart';
import '../components/app_back_button.dart';
import 'package:go_router/go_router.dart';

class RecentOrdersScreen extends StatefulWidget {
  const RecentOrdersScreen({super.key});

  @override
  State<RecentOrdersScreen> createState() => _RecentOrdersScreenState();
}

class _RecentOrdersScreenState extends State<RecentOrdersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pageCtrl;
  late Animation<double> _pageFade;
  late Animation<Offset> _pageSlide;

  @override
  void initState() {
    super.initState();

    _pageCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pageFade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageCtrl.forward();
      // Only fetch if the user is logged in — otherwise we show a sign-in
      // prompt and skip the API call entirely.
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<OrdersProvider>().fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return DateFormat('MMM d, yyyy').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    final ordersProv = context.watch<OrdersProvider>();
    // Only show orders for this app's configured business.
    final orders = ordersProv.orders
        .where((o) => o.businessId == ApiConfig.businessId)
        .toList();
    final totalSpent = orders.fold<double>(0, (sum, o) => sum + o.total);
    final width = MediaQuery.of(context).size.width;

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
        child: FadeTransition(
          opacity: _pageFade,
          child: SlideTransition(
            position: _pageSlide,
            child: !isAuthenticated
                ? _LoggedOutPrompt(width: width)
                : RefreshIndicator(
                    onRefresh: () => ordersProv.fetchOrders(),
                    child: _buildBody(ordersProv, orders, totalSpent, width),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(OrdersProvider ordersProv, List<Order> orders,
      double totalSpent, double width) {
    final horizontal = width > 400 ? 24.0 : 16.0;
    final padding = EdgeInsets.fromLTRB(horizontal, 0, horizontal, 40);

    if (ordersProv.isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ordersProv.error != null && orders.isEmpty) {
      return ListView(
        padding: padding,
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline_rounded,
              size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Center(
            child: Text('Failed to load orders',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              ordersProv.error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () => ordersProv.fetchOrders(),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (orders.isEmpty) {
      return ListView(
        padding: padding,
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text('No orders yet',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Your past orders will appear here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: padding,
      children: [
        _SummaryCard(orderCount: orders.length, totalSpent: totalSpent),
        const SizedBox(height: 24),
        ...orders.map((order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OrderTile(
                order: order,
                formattedDate: _formatDate(order.date),
                onReorder: () {
                  final products =
                      context.read<ProductProvider>().products;
                  final result = context
                      .read<CartProvider>()
                      .reorder(order, products);
                  final messenger = ScaffoldMessenger.of(context);
                  if (result.added == 0) {
                    messenger.showSnackBar(const SnackBar(
                      content: Text(
                          'None of these items are available right now.'),
                    ));
                    return;
                  }
                  final skipped = result.unavailable + result.missing;
                  if (skipped > 0) {
                    messenger.showSnackBar(SnackBar(
                      content: Text(
                          'Added ${result.added} item${result.added == 1 ? '' : 's'}; $skipped unavailable.'),
                    ));
                  }
                  context.push('/cart');
                },
              ),
            )),
      ],
    );
  }
}

class _LoggedOutPrompt extends StatelessWidget {
  final double width;

  const _LoggedOutPrompt({required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horizontal = width > 400 ? 24.0 : 16.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(horizontal, 80, horizontal, 40),
      children: [
        Icon(Icons.receipt_long_outlined,
            size: 56, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(
          'Sign in to view recent orders',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Log in to see your order history and reorder your favourites.',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: const Text('Log in'),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int orderCount;
  final double totalSpent;

  const _SummaryCard({required this.orderCount, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.onSurfaceVariant,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECENT ACTIVITY',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.tertiary,
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
                    '$orderCount',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    'orders placed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary
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
                    'Rs ${totalSpent.toStringAsFixed(0)}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'total spent',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary
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
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;
  final String formattedDate;
  final VoidCallback onReorder;

  const _OrderTile({
    required this.order,
    required this.formattedDate,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaid = order.status.toLowerCase() == 'paid';
    final invoiceLabel =
        order.invoice != null ? '#INV-${order.invoice}' : '#${order.id}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                invoiceLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (formattedDate.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  '· $formattedDate',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const Spacer(),
              if (order.status.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : theme.colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isPaid
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${item.name} × ${item.qty}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontSize: 13),
                ),
              )),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Rs ${order.total.toStringAsFixed(0)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onReorder,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Reorder',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
