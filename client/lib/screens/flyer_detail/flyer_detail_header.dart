import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';

String _categoryLabel(FlyerCategory cat) {
  switch (cat) {
    case FlyerCategory.supermarket:
      return 'Supermarché';
    case FlyerCategory.electronics:
      return 'Électronique';
    case FlyerCategory.pharmacy:
      return 'Pharmacie';
    case FlyerCategory.bakery:
      return 'Boulangerie';
    case FlyerCategory.sports:
      return 'Sport';
    case FlyerCategory.restaurant:
      return 'Restaurant';
    case FlyerCategory.fashion:
      return 'Mode';
    case FlyerCategory.other:
      return 'Autre';
  }
}

/// White header card with store logo, name, flyer title, and category chip.
class FlyerDetailHeader extends StatelessWidget {
  final Flyer flyer;

  const FlyerDetailHeader({super.key, required this.flyer});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                flyer.storeLogoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    flyer.storeName[0],
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flyer.storeName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoalText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  flyer.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            AppColors.primaryGreen.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    _categoryLabel(flyer.category),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
