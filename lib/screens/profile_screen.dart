import 'package:flutter/material.dart';
import '../../components/loyalty_card.dart';
import '../../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

import 'package:go_router/go_router.dart';
import '../../components/service_icon.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
        children: [
          Text(l10n.myProfile,
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 20),

          // Profile card
          GestureDetector(
            onTap: () => context.push('/profile/edit'),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFAF3), Color(0x66F5E6D3)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .tertiary
                        .withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: Theme.of(context)
                          .extension<AppThemeExtension>()
                          ?.primaryGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    alignment: Alignment.center,
                    child: Text('S',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sophie Martin',
                            style: Theme.of(context).textTheme.headlineLarge),
                        Text('sophie.martin@email.com',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(l10n.croissantMember,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Loyalty card
          const LoyaltyCard(),
          const SizedBox(height: 24),

          // Menu sections
          _SectionHeader(label: l10n.ordersHistory),
          const SizedBox(height: 8),
          _MenuTile(
              icon: '📦',
              label: l10n.myOrders,
              sub: l10n.recentOrdersSub,
              onTap: () => context.push('/profile/orders')),
          _MenuTile(
              icon: '❤️',
              label: l10n.favourites,
              sub: l10n.savedItemsSub,
              onTap: () => context.push('/profile/favourites')),
          const SizedBox(height: 16),
          _SectionHeader(label: l10n.account),
          const SizedBox(height: 8),
          _MenuTile(
              icon: '📍',
              label: l10n.savedAddresses,
              sub: l10n.manageLocationsSub,
              onTap: () => context.push('/profile/addresses')),
          _MenuTile(
              icon: '💳',
              label: l10n.paymentMethods,
              sub: l10n.cardsWalletsSub,
              onTap: () => context.push('/profile/payments')),
          const SizedBox(height: 16),
          _SectionHeader(label: l10n.preferences),
          const SizedBox(height: 8),
          _MenuTile(
              icon: '🔔',
              label: l10n.notifications,
              sub: l10n.pushEmailSub,
              onTap: () => context.push('/profile/notifications')),
          _MenuTile(
              icon: '⚙️',
              label: l10n.settings,
              sub: l10n.settingsSub,
              onTap: () => context.push('/profile/settings')),
          const SizedBox(height: 20),

          // Sign out
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .errorContainer
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  ServiceIcon(
                    icon: '👋',
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                  ),
                  const SizedBox(width: 14),
                  Text(l10n.signOut,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(letterSpacing: 1, fontSize: 11));
  }
}

class _MenuTile extends StatelessWidget {
  final String icon;
  final String label;
  final String? sub;
  final VoidCallback? onTap;

  const _MenuTile(
      {required this.icon, required this.label, this.sub, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ServiceIcon(
              icon: icon,
              size: 44,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyLarge),
                  if (sub != null)
                    Text(sub!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20),
          ],
        ),
      ),
    );
  }
}
