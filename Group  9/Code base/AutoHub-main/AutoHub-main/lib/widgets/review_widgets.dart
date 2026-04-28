import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/review_model.dart';
import '../theme/app_theme.dart';

// ── Rating Overview ─────────────────────────────────────────────────────────
class RatingOverview extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> breakdown; // star -> count

  const RatingOverview({super.key, required this.averageRating,
    required this.totalRatings, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(children: [
        // Big rating number
        Column(children: [
          Text(averageRating.toStringAsFixed(1), style: const TextStyle(
              fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          RatingBarIndicator(
            rating: averageRating, itemSize: 20,
            itemBuilder: (_, __) =>
            const Icon(Icons.star_rounded, color: AppTheme.starColor),
          ),
          const SizedBox(height: 4),
          Text('$totalRatings reviews', style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary)),
        ]),
        const SizedBox(width: 20),
        // Breakdown bars
        Expanded(child: Column(children: [
          for (int star = 5; star >= 1; star--)
            _BarRow(star: star, count: breakdown[star] ?? 0,
                total: totalRatings),
        ])),
      ]),
    );
  }
}

class _BarRow extends StatelessWidget {
  final int star, count, total;
  const _BarRow({required this.star, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text('$star', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const Icon(Icons.star_rounded, size: 12, color: AppTheme.starColor),
        const SizedBox(width: 6),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: AppTheme.border,
            color: AppTheme.starColor,
            minHeight: 6,
          ),
        )),
        const SizedBox(width: 6),
        SizedBox(width: 24, child: Text('$count',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary))),
      ]),
    );
  }
}

// ── Review Card ──────────────────────────────────────────────────────────────
class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback? onHelpful;

  const ReviewCard({super.key, required this.review, this.onHelpful});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary.withOpacity(0.15),
            backgroundImage: review.userPhoto != null
                ? NetworkImage(review.userPhoto!) : null,
            child: review.userPhoto == null
                ? Text(review.userName[0].toUpperCase(),
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(review.userName, style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
              if (review.isVerified) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('Verified', style: TextStyle(
                      fontSize: 9, color: AppTheme.success, fontWeight: FontWeight.bold)),
                ),
              ],
            ]),
            Text(timeago.format(review.createdAt),
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ])),
          RatingBarIndicator(
            rating: review.rating, itemSize: 14,
            itemBuilder: (_, __) =>
            const Icon(Icons.star_rounded, color: AppTheme.starColor),
          ),
        ]),
        const SizedBox(height: 10),
        if (review.title.isNotEmpty)
          Text(review.title, style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 4),
        Text(review.comment, style: const TextStyle(
            fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
        if (review.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4, children: review.tags.map((t) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(t, style: const TextStyle(
                    fontSize: 11, color: AppTheme.primary)),
              )).toList(),
          ),
        ],
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onHelpful,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.thumb_up_alt_outlined, size: 14,
                color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text('Helpful (${review.helpfulCount})',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ]),
        ),
      ]),
    );
  }
}