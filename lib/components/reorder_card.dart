import '../../theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../models/order.dart';

/// Compact order history card widget.
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onReorder;
  final bool featured;

  const OrderCard({
    super.key,
    required this.order,
    this.onReorder,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: featured
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border:
            featured ? null : Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.id,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: featured
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
              const SizedBox(width: 6),
              Text(
                '· ${order.date.split(',').first}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: featured
                          ? Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.7)
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...order.items.map((item) => Text(
                '${item.name} × ${item.qty}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: featured
                          ? Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.9)
                          : Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 13,
                    ),
              )),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: featured
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (onReorder != null) ...[
                const Spacer(),
                TextButton(
                  onPressed: onReorder,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppColors.transparent,
                    shadowColor: AppColors.transparent,
                  ),
                  child: Text(
                    'Reorder',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: featured
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: featured
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.5)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.5),
                        ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
