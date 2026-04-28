import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/vehicle_model.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  const VehicleCard({super.key, required this.vehicle,
    required this.onTap, this.isSaved = false, this.onToggleSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image with badges
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: vehicle.imageUrls.isNotEmpty ? vehicle.imageUrls.first : '',
                height: 180, width: double.infinity, fit: BoxFit.cover,
                placeholder: (_, __) => const ShimmerBox(
                    width: double.infinity, height: 180, borderRadius: 0),
                errorWidget: (_, __, ___) => Container(
                    height: 180, color: AppTheme.border,
                    child: const Icon(Icons.directions_car, size: 60,
                        color: AppTheme.textSecondary)),
              ),
            ),
            // Type badge
            Positioned(top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(vehicle.type.toUpperCase(),
                    style: const TextStyle(color: Colors.white,
                        fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
            // Verified badge
            if (vehicle.isVerified)
              Positioned(top: 12, right: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(6)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.verified, size: 10, color: Colors.white),
                    SizedBox(width: 3),
                    Text('Verified', style: TextStyle(
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            // Wishlist button
            Positioned(top: 8, right: 8,
              child: GestureDetector(
                onTap: onToggleSave,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.15), blurRadius: 4)]),
                  child: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    size: 18, color: isSaved ? AppTheme.error : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ]),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(vehicle.title, style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(vehicle.priceLabel, style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold,
                    color: AppTheme.primary)),
              ]),
              const SizedBox(height: 6),

              // Spec chips
              Wrap(spacing: 6, runSpacing: 4, children: [
                _Chip('${vehicle.year}'),
                _Chip(vehicle.fuelType),
                _Chip(vehicle.transmission),
                if (vehicle.engineCC > 0) _Chip('${vehicle.engineCC}cc'),
              ]),
              const SizedBox(height: 8),

              // Location
              Row(children: [
                const Icon(Icons.location_on, size: 13,
                    color: AppTheme.textSecondary),
                const SizedBox(width: 3),
                Expanded(child: Text(vehicle.city, style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary))),
              ]),
              const SizedBox(height: 8),

              // Rating + tags row
              Row(children: [
                RatingBarIndicator(
                  rating: vehicle.averageRating,
                  itemSize: 14,
                  itemBuilder: (_, __) => const Icon(
                      Icons.star_rounded, color: AppTheme.starColor),
                ),
                const SizedBox(width: 4),
                Text('${vehicle.averageRating.toStringAsFixed(1)} '
                    '(${vehicle.totalRatings})',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                const Spacer(),
                if (vehicle.forSale) _Tag('For Sale', AppTheme.success),
                if (vehicle.forRent) ...[
                  const SizedBox(width: 6),
                  _Tag('₹${vehicle.rentPerHour.toInt()}/hr', AppTheme.warning),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: AppTheme.border.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: const TextStyle(
        fontSize: 11, color: AppTheme.textSecondary)),
  );
}

class _Tag extends StatelessWidget {
  final String label; final Color color;
  const _Tag(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(
        fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );
}