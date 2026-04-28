import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
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
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.transparent,
              shadowColor: AppColors.transparent,
            ),
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
                        padding: width > 400?const EdgeInsets.fromLTRB(24, 0, 24, 20):const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                        left: 24,
                        right: 24,
                        child: PrimaryButton(
                          label: _step < 2
                              ? l10n.continueBtn
                              : '${l10n.placeOrder} — Rs ${cart.total.toStringAsFixed(0)}',
                          onTap: () {
                            if (_step < 2) {
                              setState(() => _step++);
                            } else {
                              // Navigate to login screen before order success
                              context.go('/cart/checkout/login?from=checkout');
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
    final isCompleted = step < current;
    
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              // Left connector line
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.darkBrown
                        : AppColors.beige,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              
              // Step circle with number
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 30,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppColors.darkBrown 
                      : isCurrent 
                          ? AppColors.darkBrown 
                          : AppColors.warmWhite,
                  border: Border.all(
                    color: active ? AppColors.darkBrown : AppColors.beige,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.darkBrown.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.cream,
                          size: 15,
                        )
                      : Text(
                          '$step',
                          style: TextStyle(
                            color: active ? AppColors.cream : AppColors.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              
              // Right connector line
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.darkBrown
                        : AppColors.beige,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.darkBrown : AppColors.textLight,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Step1 extends StatefulWidget {
  final dynamic addr;

  const _Step1({required this.addr, super.key});

  @override
  State<_Step1> createState() => _Step1State();
}

class _Step1State extends State<_Step1> {
  void _showAddressSheet() {
    final addrProv = context.read<AddressProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressBottomSheet(
        selectedId: addrProv.selectedId,
        onSelect: (id) => addrProv.select(id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final addr = widget.addr;
    final isPickup = addr.type == 'Pickup';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${isPickup ? l10n.pickup : l10n.delivery} ${l10n.details}',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _showAddressSheet,
          child: _InfoTile(
            label: isPickup ? l10n.pickupLocation : l10n.deliveryAddress,
            icon: addr.icon,
            title: addr.label,
            subtitle: addr.address,
            showChevron: true,
          ),
        ),
        const SizedBox(height: 12),
        _InfoTile(
          label: '${isPickup ? l10n.pickup : l10n.delivery} ${l10n.timeLabel}',
          icon: Icons.access_time_rounded,
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

/// Address selection bottom sheet for checkout
class _AddressBottomSheet extends StatelessWidget {
  final int selectedId;
  final ValueChanged<int> onSelect;

  const _AddressBottomSheet({
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<AddressProvider>().addresses;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Select ${addresses.any((a) => a.type == 'Pickup') ? 'Pickup Location' : 'Address'}',
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            ...addresses.map((addr) {
              final isSelected = addr.id == selectedId;
              return GestureDetector(
                onTap: () {
                  onSelect(addr.id);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.beige : AppColors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.darkBrown : AppColors.beige,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.darkBrown.withValues(alpha: 0.1)
                              : AppColors.beige,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          addr.icon,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(addr.label,
                                style: AppTextStyles.bodyLarge
                                    .copyWith(fontWeight: FontWeight.w500)),
                            Text(addr.address,
                                style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_rounded,
                            color: AppColors.sage, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final dynamic icon;
  final String title;
  final String? subtitle;
  final bool showChevron;

  const _InfoTile({
    required this.label,
    required this.icon,
    required this.title,
    this.subtitle,
    this.showChevron = false,
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
                if (icon is String)
                  Text(icon as String, style: const TextStyle(fontSize: 16)),
                if (icon is IconData)
                  Icon(icon as IconData, size: 16, color: Theme.of(context).colorScheme.primary),
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
                if (showChevron)
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 20),
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

    final List<({IconData icon, String label, String sub})> methods = [
      (icon: Icons.qr_code_2_rounded, label: 'QR Payment', sub: 'Scan to pay'),
      (icon: Icons.money_rounded, label: 'Cash on Delivery', sub: l10n.payOnDelivery),
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
        ...cart.items.map((item) {
          final hasAddons = item.selectedAddonQuantities.isNotEmpty &&
              item.selectedAddonQuantities.values.any((q) => q > 0);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 4,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               item.product.name,
                               style: textTheme.bodySmall,
                               overflow: TextOverflow.ellipsis,
                             ),
                             // Show selected variant name
                             if (item.variantName != null && item.variantName!.isNotEmpty)
                               Text(
                                 item.variantName!,
                                 style: textTheme.bodySmall?.copyWith(
                                   color: textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                   fontSize: 11,
                                 ),
                               ),
                           ],
                         )),
                    Expanded(
                        child: Text('x ${item.quantity}',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall)),
                    Expanded(
                        flex: 2,
                        child: Text(
                          item.effectivePrice.toStringAsFixed(0),
                          textAlign: TextAlign.right,
                          style: textTheme.bodySmall,
                        )),
                    Expanded(
                        flex: 2,
                        child: Text(
                          (item.effectivePrice * item.quantity).toStringAsFixed(0),
                          textAlign: TextAlign.right,
                          style: textTheme.bodySmall,
                        )),
                  ],
                ),
                // Show addon details if any
                if (hasAddons)
                  ...item.selectedAddonQuantities.entries.where((e) => e.value > 0).map((entry) {
                    final addonIndex = entry.key;
                    final addonQty = entry.value;
                    if (addonIndex < item.product.addons.length) {
                      final addon = item.product.addons[addonIndex];
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, top: 2),
                         child: Text(
                           '  ${addon.name} x${addonQty * item.quantity} - Rs ${(addon.price * addonQty * item.quantity).toStringAsFixed(0)}',
                           style: textTheme.bodySmall?.copyWith(
                             color: textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                             fontSize: 11,
                           ),
                         ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
              ],
            ),
          );
        }),
        const Divider(height: 32),

        // --- Totals ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.subtotal, style: textTheme.bodyMedium),
            Text('Rs ${cart.subtotal.toStringAsFixed(0)}',
                style: textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.deliveryFee, style: textTheme.bodyMedium),
            Text('Rs ${CartProvider.deliveryFee.toStringAsFixed(0)}',
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
            Text('Rs ${cart.total.toStringAsFixed(0)}',
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
            Text(
              '${l10n.paymentModeLabel}: ${selected == 0 ? "QR Payment" : "Cash"}',
              style: textTheme.bodyMedium,
            ),
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
                    Icon(m.icon, size: 20, color: colorScheme.primary),
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
