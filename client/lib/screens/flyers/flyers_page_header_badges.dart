part of '../flyers_page.dart';

extension _FlyersPageHeaderBadges on _FlyersPageState {
  Widget _buildRecentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.urgencyOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.urgencyOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fiber_new, size: 14, color: AppColors.urgencyOrange),
          const SizedBox(width: 4),
          Text(
            'Nouveau',
            style: GoogleFonts.poppins(
              color: AppColors.urgencyOrange,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceBadge(Flyer flyer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 14, color: AppColors.primaryGreen),
          const SizedBox(width: 2),
          Text(
            '${_getDistance(flyer).toStringAsFixed(1)} km',
            style: GoogleFonts.poppins(
              color: AppColors.primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
