import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import 'package:intl/intl.dart';
import '../../components/primary_button.dart';
import '../../components/empty_cart_view.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 1; // 1 = delivery, 2 = payment & confirm
  int _selectedPayment = 2; // Default to Cash

  String _stepLabel(Address addr, AppLocalizations l10n) =>
      addr.type == 'Pickup' ? l10n.pickup : l10n.delivery;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addr = context.watch<AddressProvider>().selected;
    final l10n = AppLocalizations.of(context)!;
    final step1Label = _stepLabel(addr, l10n);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(l10n.checkout),
      ),
      body: SafeArea(
        child: cart.items.isEmpty
            ? const EmptyCartView()
            : Stack(
                children: [
                  Column(
                    children: [
                      // Step indicator
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Row(
                          children: [
                            _StepIndicator(
                                label: step1Label, step: 1, current: _step),
                            const SizedBox(width: 6),
                            _StepIndicator(
                                label: l10n.paymentConfirm,
                                step: 2,
                                current: _step),
                          ],
                        ),
                      ),

                      // Step content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _step == 1
                                ? _Step1(addr: addr, key: const ValueKey(1))
                                : _Step2(
                                    cart: cart,
                                    addr: addr,
                                    selected: _selectedPayment,
                                    onSelect: (i) =>
                                        setState(() => _selectedPayment = i),
                                    key: const ValueKey(2),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // CTA Button
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: PrimaryButton(
                      label: _step < 2
                          ? l10n.continueBtn
                          : '${l10n.placeOrder} — Rs ${cart.total.toStringAsFixed(2)}',
                      onTap: () {
                        if (_step < 2) {
                          setState(() => _step++);
                        } else {
                          context.go('/cart/checkout/success');
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

class _StepIndicator extends StatelessWidget {
  final String label;
  final int step;
  final int current;

  const _StepIndicator(
      {required this.label, required this.step, required this.current});

  @override
  Widget build(BuildContext context) {
    final active = step <= current;
    final isCurrent = step == current;
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 3,
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

class _Step1 extends StatelessWidget {
  final dynamic addr;

  const _Step1({required this.addr, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPickup = addr.type == 'Pickup';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${isPickup ? l10n.pickup : l10n.delivery} ${l10n.details}',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _InfoTile(
          label: isPickup ? l10n.pickupLocation : l10n.deliveryAddress,
          icon: addr.icon,
          title: addr.label,
          subtitle: addr.address,
        ),
        const SizedBox(height: 12),
        _InfoTile(
          label: '${isPickup ? l10n.pickup : l10n.delivery} ${l10n.timeLabel}',
          icon: '🕐',
          title:
              'Today, ${DateFormat('h:mm a').format(DateTime.now().add(const Duration(minutes: 25)))}',
          subtitle: null,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.specialInstructions,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontSize: 11, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: l10n.specialInstructionsHint,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                    border: InputBorder.none,
                    isDense: false,
                    contentPadding: const EdgeInsets.only(top: 8),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String icon;
  final String title;
  final String? subtitle;

  const _InfoTile({
    required this.label,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 11, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Step2 extends StatelessWidget {
  final CartProvider cart;
  final dynamic addr;
  final int selected;
  final ValueChanged<int> onSelect;

  const _Step2({
    required this.cart,
    required this.addr,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final List<({String icon, String label, String sub})> methods = [
      (icon: '💳', label: '•••• 4289', sub: '${l10n.visaEnding} 4289'),
      (icon: '🍎', label: l10n.applePay, sub: l10n.expressCheckout),
      (icon: '💵', label: l10n.cashLabel, sub: l10n.payOnDelivery),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Receipt Header ---
        Center(
          child: Text(
            l10n.businessName,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.warehouse, style: textTheme.bodyMedium),
            Text('${l10n.billNo} 378', style: textTheme.bodyMedium),
          ],
        ),
        const Divider(height: 32),

        // --- Items Ordered Section ---
        Text(
          l10n.itemsOrdered,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(l10n.name,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  )),
            ),
            Expanded(
                child: Text(l10n.qty,
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ))),
            Expanded(
                flex: 2,
                child: Text(l10n.rate,
                    textAlign: TextAlign.right,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ))),
            Expanded(
                flex: 2,
                child: Text(l10n.amount,
                    textAlign: TextAlign.right,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ))),
          ],
        ),
        const SizedBox(height: 8),
        ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child:
                          Text(item.product.name, style: textTheme.bodySmall)),
                  Expanded(
                      child: Text('x ${item.quantity}',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall)),
                  Expanded(
                      flex: 2,
                      child: Text(item.product.price.toStringAsFixed(2),
                          textAlign: TextAlign.right,
                          style: textTheme.bodySmall)),
                  Expanded(
                      flex: 2,
                      child: Text(
                          (item.product.price * item.quantity)
                              .toStringAsFixed(2),
                          textAlign: TextAlign.right,
                          style: textTheme.bodySmall)),
                ],
              ),
            )),
        const Divider(height: 32),

        // --- Totals ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.totalLabel, style: textTheme.bodyMedium),
            Text('Rs ${cart.total.toStringAsFixed(2)}',
                style: textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.discount, style: textTheme.bodyMedium),
            Text('Rs 0.00', style: textTheme.bodyMedium),
          ],
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.grandTotal,
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text('Rs ${cart.total.toStringAsFixed(2)}',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(height: 32),

        // --- Cashier Details ---
        Text(l10n.cashier,
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Suraj Giri', style: TextStyle(fontSize: 14)), // Not localizing names
            Text('${l10n.paymentModeLabel}: cash', style: textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${l10n.counter}: POS12', style: textTheme.bodyMedium),
            Text(
                '${l10n.dateLabel}: ${DateFormat('MM/dd/yyyy hh:mm:ss a').format(DateTime.now())}',
                style: textTheme.bodySmall),
          ],
        ),
        const Divider(height: 32),

        // --- Buzz Points ---
        Text(l10n.buzzPoints,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.currentLabel,
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const Text('0', style: TextStyle(fontSize: 11)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.totalLabel,
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const Text('0.00', style: TextStyle(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 32),

        // --- Original Payment Method Selection ---
        Text(l10n.changePayment,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...methods.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          final isSelected = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? colorScheme.primary : theme.dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(m.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.label,
                              style: textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text(m.sub, style: textTheme.labelSmall),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle,
                          color: colorScheme.primary, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
