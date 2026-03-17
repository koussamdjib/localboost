import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _buildDateLabel(Flyer flyer) {
  if (flyer.startDate != null && flyer.endDate != null) {
    return 'Du ${_fmtDate(flyer.startDate!)} au ${_fmtDate(flyer.endDate!)}';
  }
  if (flyer.endDate != null) {
    return 'Valable jusqu\'au ${_fmtDate(flyer.endDate!)}';
  }
  if (flyer.startDate != null) {
    return 'À partir du ${_fmtDate(flyer.startDate!)}';
  }
  return flyer.validUntil;
}

/// Card showing flyer description and validity dates.
class FlyerDetailInfoCard extends StatelessWidget {
  final Flyer flyer;

  const FlyerDetailInfoCard({super.key, required this.flyer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (flyer.description != null &&
              flyer.description!.isNotEmpty) ...[
            Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoalText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              flyer.description!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _buildDateLabel(flyer),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.charcoalText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
