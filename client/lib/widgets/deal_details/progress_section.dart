import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

/// Stamp progress display with circular indicators
class ProgressSection extends StatelessWidget {
  final int totalRequired;
  final int currentStamps;

  const ProgressSection({
    super.key,
    required this.totalRequired,
    required this.currentStamps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progression',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final circleSize =
                ((availableWidth - (totalRequired - 1) * 10) / totalRequired)
                    .clamp(38.0, 48.0);
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              children: List.generate(
                totalRequired,
                (index) => Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: index < currentStamps
                        ? AppColors.primaryGreen
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    boxShadow: index < currentStamps
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      index < currentStamps
                          ? Icons.check
                          : Icons.circle_outlined,
                      color: index < currentStamps
                          ? Colors.white
                          : Colors.grey.shade400,
                      size: circleSize * 0.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Text(
          '$currentStamps/$totalRequired Timbres',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade700,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
