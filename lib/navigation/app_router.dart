import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../models/product.dart';
import 'app_shell.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_success_screen.dart';
import '../screens/recent_orders_screen.dart';
import '../screens/favourites_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/profile_sub_screens.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _favouritesNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'favourites');
final GlobalKey<NavigatorState> _cartNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'cart');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Lottie.asset('assets/animations/error_404.json',
                width: 250, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          Text('Something went wrong',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text("We couldn't find the page you're looking for.",
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              while (context.canPop()) {
                context.pop();
              }
              context.go('/home');
            },
            child: const Text('Return to Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'product',
                  builder: (context, state) {
                    final product = state.extra as Product;
                    return ProductDetailScreen(product: product);
                  },
                ),
                GoRoute(
                  path: 'recent_orders',
                  builder: (context, state) => const RecentOrdersScreen(),
                ),
              ],
            ),
          ],
        ),

        // Branch 1: Favourites
        StatefulShellBranch(
          navigatorKey: _favouritesNavigatorKey,
          routes: [
            GoRoute(
              path: '/favourites',
              builder: (context, state) => const FavouritesScreen(),
              routes: [
                GoRoute(
                  path: 'product',
                  builder: (context, state) {
                    final product = state.extra as Product;
                    return ProductDetailScreen(product: product);
                  },
                ),
              ],
            ),
          ],
        ),

        // Branch 2: Cart & Checkout flow
        StatefulShellBranch(
          navigatorKey: _cartNavigatorKey,
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartScreen(),
              routes: [
                GoRoute(
                  path: 'checkout',
                  builder: (context, state) => const CheckoutScreen(),
                  routes: [
                    GoRoute(
                      path: 'success',
                      builder: (context, state) => const OrderSuccessScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Branch 3: Profile
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'addresses',
                  builder: (context, state) => const SavedAddressesScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const AddNewAddressScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'payments',
                  builder: (context, state) => const PaymentMethodsScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'orders',
                  builder: (context, state) => const RecentOrdersScreen(),
                ),
                GoRoute(
                  path: 'favourites',
                  builder: (context, state) => const FavouritesScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
