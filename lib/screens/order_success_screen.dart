import 'package:flutter/material.dart';
import '../../components/primary_button.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;


  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..forward();
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _scaleAnim =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Localized steps
    final List<({String desc, IconData icon, String label})> localizedSteps = [
      (icon: Icons.check_circle_rounded, label: l10n.orderConfirmed, desc: l10n.orderConfirmedDesc),
      (icon: Icons.restaurant_menu_rounded, label: l10n.preparing, desc: l10n.preparingDesc),
      (
        icon: Icons.local_shipping_rounded,
        label: l10n.readyForPickup,
        desc:
            '${l10n.readyForPickupDesc} ${DateFormat('h:mm a').format(DateTime.now().add(const Duration(minutes: 25)))}'
      ),
    ];

    // Navigate to target location, resetting the cart branch stack first
    void navigateAway(String targetPath) {
      // First navigate to cart root to reset the branch's navigation stack,
      // then navigate to the target location.
      context.go('/cart');
      // Small delay to allow the branch state to reset
      final router = GoRouter.of(context);
      Future.delayed(const Duration(milliseconds: 50), () {
        router.go(targetPath);
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          navigateAway('/home');
        }
      },
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Success icon
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        const Color(0xFF88B07A)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text('✓',
                      style: TextStyle(
                          fontSize: 52,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w300)),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.celebration_rounded, 
                            color: Theme.of(context).colorScheme.primary, 
                            size: 28),
                        const SizedBox(width: 8),
                        Text(l10n.orderPlaced,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(fontSize: 26)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '#OD-2849 • ${l10n.estReadyAt} 11:00 AM',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Progress
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.orderProgress,
                              style: Theme.of(context).textTheme.headlineSmall),
                          Text(l10n.stepXofY(1, 3),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...localizedSteps.asMap().entries.map((e) {
                        final i = e.key;
                        final s = e.value;
                        final isActive = i == 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : Theme.of(context)
                                          .dividerColor
                                          .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: Icon(s.icon, 
                                    size: 18,
                                    color: isActive 
                                        ? Theme.of(context).colorScheme.primary 
                                        : Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: isActive
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                              fontWeight: isActive
                                                  ? FontWeight.w500
                                                  : FontWeight.w400,
                                            )),
                                    Text(s.desc,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (isActive)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: l10n.recentOrders,
                onTap: () {
                  navigateAway('/profile/orders');
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  navigateAway('/home');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: Text(l10n.continueShopping,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
