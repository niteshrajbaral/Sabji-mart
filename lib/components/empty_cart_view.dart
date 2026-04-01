import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../l10n/app_localizations.dart';
import './browse_menu_button.dart';

class EmptyCartView extends StatelessWidget {
  final VoidCallback? onBack;

  const EmptyCartView({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Lottie.asset(
              'assets/animations/empty_cart.json',
              width: 250,
              repeat: false,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon if Lottie fails or asset is missing
                return Icon(Icons.shopping_basket_outlined,
                    size: 100, color: Theme.of(context).colorScheme.outline);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyCartTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emptyCartSub,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          BrowseMenuButton(onTap: onBack),
        ],
      ),
    );
  }
}
