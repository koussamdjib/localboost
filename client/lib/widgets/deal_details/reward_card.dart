import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

/// Reward display card with icon and value
class RewardCard extends StatelessWidget {
  final String rewardIcon;
  final String rewardValue;

  const RewardCard({
    super.key,
    required this.rewardIcon,
    required this.rewardValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.18),
            AppColors.primaryGreen.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Text(
            rewardIcon,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Récompense',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rewardValue,
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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
