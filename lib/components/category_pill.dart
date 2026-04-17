import 'package:flutter/material.dart';

/// Category filter pill chip (Custom implementation to avoid ChoiceChip overflows).
class CategoryPill extends StatelessWidget {
  final String label;

  final bool active;
  final VoidCallback onTap;

  const CategoryPill({
    super.key,
    required this.label,

    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: active ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active ? colorScheme.primary : theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? colorScheme.primary : theme.dividerColor,
                width: 1.5,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: active ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}