import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import 'package:lottie/lottie.dart';

import '../../providers/favourites_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../components/grid_product_card.dart';
import '../../components/browse_menu_button.dart';
import 'package:go_router/go_router.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();
    final favProv = context.watch<FavouritesProvider>();
    final cart = context.read<CartProvider>();
    final width = MediaQuery.of(context).size.width;
    final favs =
        productProv.products.where((p) => favProv.isFavourite(p.id)).toList();

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
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
          ),
          title: Text('My Favourites'),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: width > 400
                    ? const EdgeInsets.fromLTRB(24, 0, 24, 20)
                    : const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                        '${favs.length} saved item${favs.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.end),
                  ],
                ),
              ),
              Expanded(
                child: favs.isEmpty
                    ? _EmptyFavourites()
                    : GridView.builder(
                        padding: width > 400
                            ? const EdgeInsets.fromLTRB(24, 0, 24, 100)
                            : const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        gridDelegate: _gridDelegateFor(width),
                        itemCount: favs.length,
                        itemBuilder: (_, i) {
                          final p = favs[i];
                          return GridProductCard(
                            product: p,
                            onTap: () =>
                                context.push('/favourites/product', extra: p),
                            onQuickAdd: () => cart.addProduct(p),
                            isFavourite: favProv.isFavourite(p.id),
                            onToggleFavourite: () => favProv.toggle(p.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ));
  }
}

class _EmptyFavourites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Lottie.asset('assets/animations/empty_fav.json',
                  width: 250, repeat: false, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Text('No favourites yet',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text("Tap the ♡ on any item to save it here",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            const BrowseMenuButton(),
          ],
        ),
      ),
    );
  }
}
