import 'package:flutter/material.dart';

/// Brand colour palette for Sabji mart — Fruit & Vegetable Wholesaler.
/// Single source of truth — never hard-code colours elsewhere.
abstract final class AppColors {
  static const Color cream = Color(0xFFE8F5E9);         // scaffold background (darker)
  static const Color beige = Color(0xFFC8E6C9);         // light surface / borders (darker)
  static const Color warmWhite = Color(0xFFF1F8E9);     // card backgrounds (darker)
  static const Color softBrown = Color(0xFF2D7A55);     // medium green
  static const Color darkBrown = Color(0xFF1A4731);     // deep forest green (primary)
  static const Color caramel = Color(0xFF52B788);       // fresh leaf green (secondary)
  static const Color golden = Color(0xFF74C69D);        // mid-light green
  static const Color accent = Color(0xFF1A7A40);        // vivid green accent
  static const Color lightGold = Color(0xFFC7E8D4);    // pale mint
  static const Color terracotta = Color(0xFFE05A3A);   // warm orange-red (error/warning)
  static const Color sage = Color(0xFF95C0A4);          // muted sage
  static const Color roseDust = Color(0xFFC9A9A6);     // keep for subtle warm accents
  static const Color text = Color(0xFF1B3829);          // dark green text
  static const Color textLight = Color(0xFF5B7A68);     // muted green text
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color shadow = Color(0x141A4731);        // deep-green shadow

  // Gradient shortcuts
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBrown, softBrown],
  );

  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [beige, lightGold, golden],
    stops: [0.0, 0.5, 1.0],
  );

  static const Gradient productImageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [beige, lightGold],
  );
}
