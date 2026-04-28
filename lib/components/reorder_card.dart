import '../../theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String get _formattedDate {
    if (order.date.isEmpty) return '';
    final dt = DateTime.tryParse(order.date);
    if (dt == null) return order.date.split(',').first;
    return DateFormat('MMM d').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    const maxVisibleItems = 2;
    final visibleItems = order.items.take(maxVisibleItems).toList();
    final hiddenCount = order.items.length - visibleItems.length;
    final mutedColor = featured
        ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9)
        : Theme.of(context).textTheme.bodySmall?.color;

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
                order.invoice != null ? '#INV-${order.invoice}' : order.id,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: featured
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
              if (_formattedDate.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  '· $_formattedDate',
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
            ],
          ),
          const SizedBox(height: 10),
          // Cap items to a fixed count so the card keeps a predictable height;
          // any overflow is summarised as "+N more".
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...visibleItems.map(
                  (item) => Text(
                    '${item.name} × ${item.qty}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                          fontSize: 13,
                        ),
                  ),
                ),
                if (hiddenCount > 0)
                  Text(
                    '+$hiddenCount more',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Rs ${order.total.toStringAsFixed(0)}',
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
