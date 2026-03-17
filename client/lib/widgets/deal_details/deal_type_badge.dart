import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

/// Color-coded badge for deal type (Flash/Loyalty/Deal)
class DealTypeBadge extends StatelessWidget {
  final String dealType;

  const DealTypeBadge({
    super.key,
    required this.dealType,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (dealType) {
      case 'Flash Sale':
        bgColor = AppColors.urgencyOrange.withValues(alpha: 0.1);
        textColor = AppColors.urgencyOrange;
        icon = Icons.flash_on;
        break;
      case 'Loyalty':
        bgColor = AppColors.primaryGreen.withValues(alpha: 0.1);
        textColor = AppColors.primaryGreen;
        icon = Icons.loyalty;
        break;
      default:
        bgColor = AppColors.accentBlue.withValues(alpha: 0.1);
        textColor = AppColors.accentBlue;
        icon = Icons.local_offer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            dealType,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
