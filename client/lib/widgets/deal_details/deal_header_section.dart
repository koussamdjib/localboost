import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_client/widgets/deal_details/deal_type_badge.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

/// Header section with shop name, timer, and deal type badge
class DealHeaderSection extends StatelessWidget {
  final String shopName;
  final String dealType;
  final String timeLeft;

  const DealHeaderSection({
    super.key,
    required this.shopName,
    required this.dealType,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                shopName,
                style: GoogleFonts.poppins(
                  color: AppColors.charcoalText,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if ((dealType == 'Flash Sale' || dealType == 'Deal') &&
                timeLeft.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.urgencyOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      timeLeft,
                      style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DealTypeBadge(dealType: dealType),
      ],
    );
  }
}
