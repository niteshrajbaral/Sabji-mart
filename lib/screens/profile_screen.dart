import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../components/loyalty_card.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../../components/service_icon.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    
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
                    child: Text(
                      authProvider.userInitials,
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.customerName ?? 'Guest User',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        Text(
                          user != null 
                              ? 'Logged in'
                              : 'Not logged in',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        if (user != null)
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
                            child: Text(l10n.vipMember,
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
              icon: Icons.local_shipping_outlined,
              label: l10n.myOrders,
              sub: l10n.recentOrdersSub,
              onTap: () => context.push('/profile/orders')),
          const SizedBox(height: 16),
          _SectionHeader(label: l10n.account),
          const SizedBox(height: 8),
          _MenuTile(
              icon: Icons.location_on_outlined,
              label: l10n.savedAddresses,
              sub: l10n.manageLocationsSub,
              onTap: () => context.push('/profile/addresses')),
          const SizedBox(height: 16),
          _SectionHeader(label: l10n.preferences),
          const SizedBox(height: 8),
          _MenuTile(
              icon: Icons.notifications_outlined,
              label: l10n.notifications,
              sub: l10n.pushEmailSub,
              onTap: () => context.push('/profile/notifications')),
          const SizedBox(height: 16),
          _SectionHeader(label: l10n.language),
          const SizedBox(height: 8),
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, _) {
              final isNepali = localeProvider.locale.languageCode == 'ne';
              return _LanguageToggle(
                isNepali: isNepali,
                onToggle: () => localeProvider.toggleLocale(),
              );
            },
          ),
          const SizedBox(height: 20),

          // Sign out button
          if (authProvider.isAuthenticated)
            GestureDetector(
              onTap: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.signOut),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          l10n.signOut,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signed out successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.signOut,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            )
          else
            // Login button for non-authenticated users
            GestureDetector(
              onTap: () => context.push('/cart/checkout/login'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: Theme.of(context)
                      .extension<AppThemeExtension>()
                      ?.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      color: AppColors.cream,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.login,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.cream,
                            fontWeight: FontWeight.w500)),
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
  final dynamic icon;
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

class _LanguageToggle extends StatelessWidget {
  final bool isNepali;
  final VoidCallback onToggle;

  const _LanguageToggle({required this.isNepali, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ServiceIcon(
              icon: Icons.language_outlined,
              size: 44,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.language,
                      style: Theme.of(context).textTheme.bodyLarge),
                  Text(
                    isNepali ? l10n.nepali : l10n.english,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Switch(
              value: isNepali,
              onChanged: (_) => onToggle(),
              activeThumbColor: Theme.of(context).colorScheme.onPrimary,
              activeTrackColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}