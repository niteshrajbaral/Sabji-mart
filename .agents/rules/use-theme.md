---
trigger: always_on
---

Here is why it is considered an absolute requirement for clean code:

1. Single Source of Truth
When you hardcode color: Colors.blue in 50 different widgets, changing your brand color to "Indigo" means searching and replacing 50 files.

By using Theme.of(context).primaryColor, you change one line in your ThemeData, and the entire app updates instantly. This is the "Don't Repeat Yourself" (DRY) principle in action.

2. Dynamic Dark Mode Support
Modern apps are expected to support Dark Mode. If you hardcode colors, your app will be unreadable when the user switches their system settings.

Without Theme: You have to write if (isDark) Colors.white else Colors.black inside every widget.

With Theme: Flutter automatically switches between your theme and darkTheme definitions. Your widgets simply ask for Theme.of(context).colorScheme.surface, and the framework provides the correct shade.

3. Visual Consistency
Design systems rely on a limited palette of colors and typography. Using Theme ensures:

Typography: All headers use the same font weight and letter spacing (e.g., textTheme.headlineMedium).

Spacing: Consistent border radii and button padding across the app.

User Expectation: Interactive elements feel like they belong to the same "family," which improves the UX.

4. Platform Adaptability
Flutter is multi-platform. A theme allows you to define how components should look on iOS (Cupertino) vs. Android (Material) without rewriting the widget logic. You can adjust densities and component themes (like SliderTheme or CardTheme) globally to match the target OS's design language.

How to access it correctly
To keep your code clean, always access the theme via the BuildContext.

Dart
// Instead of this:
Text('Hello', style: TextStyle(color: Colors.black, fontSize: 24))

// Do this:
Text(
  'Hello', 
  style: Theme.of(context).textTheme.displayLarge?.copyWith(
    color: Theme.of(context).colorScheme.primary,
  ),
)
Pro-Tip: ColorScheme over PrimaryColor
In modern Flutter (Material 3), move away from primaryColor and use the ColorScheme object. It provides more semantic options like onPrimary (the color for text sitting on top of the primary color) and secondaryContainer.