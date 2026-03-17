import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

/// Remaining stamps info box
class RemainingStampsBox extends StatelessWidget {
  final bool isComplete;
  final int remainingStamps;

  const RemainingStampsBox({
    super.key,
    required this.isComplete,
    required this.remainingStamps,
  });

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.celebration,
                color: AppColors.primaryGreen, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Félicitations ! Votre récompense est débloquée !',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              remainingStamps == 1
                  ? 'Plus qu\'1 timbre pour débloquer votre récompense !'
                  : 'Plus que $remainingStamps timbres pour débloquer votre récompense !',
              style: GoogleFonts.poppins(
                color: Colors.blue.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
