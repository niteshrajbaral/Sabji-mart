# La Petite Boulangerie

A beautiful, functional, and fully-themed Veg App built with Flutter. Originally translated from a React codebase, this mobile app implements modern Flutter best practices, clean architecture, responsive UI components, and state management using `Provider`.

## Features
* **Home Screen**: Browse categories, search products, use dietary filters, and toggle between grid and list layouts.
* **Product Details**: View product info, hero images, customize dietary options, and add to cart.
* **Cart & Checkout**: Manage cart items, select pickup/delivery addresses, and complete the 3-step checkout flow.
* **Favorites**: Save and manage your favorite fruits and vegetables.
* **Profile Management**: Manage saved addresses, dietary preferences, payment methods, and notification settings.

## Design
The app features a custom Material Design theme centralized in `lib/theme/`. It relies heavily on standard Material widgets (`Card`, `ChoiceChip`, `FilterChip`, `ListTile`, `IconButton`) natively styled with custom colors, typography (DM Serif Display and DM Sans), and borders to deliver a premium, cohesive aesthetic throughout the screens while eliminating code duplication.

## Getting Started

### Prerequisites
* Flutter SDK (latest stable)
* Dart SDK

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```
