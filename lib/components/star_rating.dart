import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Star rating display.
class StarRating extends StatelessWidget {
  final double rating;
  final int total;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.total = 5,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        return Icon(
          i < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
          color: i < rating.round() ? AppColors.accent : AppColors.beige,
          size: size,
        );
      }),
    );
  }
}

/// Horizontal rating bar showing per-star distribution.
class RatingBar extends StatelessWidget {
  final double rating;
  final int reviews;

  const RatingBar({
    super.key,
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    // Simulated distribution
    const Map<int, int> dist = {5: 78, 4: 16, 3: 4, 2: 2, 1: 0};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.beige),
      ),
      child: Row(
        children: [
          // Avg score
          Column(
            children: [
              Text(
                rating.toString(),
                style: AppTextStyles.displayMedium.copyWith(fontSize: 32),
              ),
              StarRating(rating: rating, size: 12),
            ],
          ),
          const SizedBox(width: 16),
          // Per-star bars
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((s) {
                final pct = dist[s] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                        child: Text('$s', style: AppTextStyles.caption),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            backgroundColor: AppColors.beige,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.golden),
                            minHeight: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
