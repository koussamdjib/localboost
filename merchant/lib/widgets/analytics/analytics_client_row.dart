import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';

/// Ranked client row: medal badge, name, stamp progress bar.
class AnalyticsClientRow extends StatelessWidget {
  final int rank;
  final Enrollment enrollment;

  const AnalyticsClientRow({
    super.key,
    required this.rank,
    required this.enrollment,
  });

  @override
  Widget build(BuildContext context) {
    final name = enrollment.customerName?.isNotEmpty == true
        ? enrollment.customerName!
        : (enrollment.customerEmail ?? 'Client inconnu');
    final stamps = enrollment.stampsCollected;
    final required = enrollment.stampsRequired;
    final progress = required > 0 ? (stamps / required).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _MedalBadge(rank: rank),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          enrollment.isCompleted
                              ? AppColors.primaryGreen
                              : AppColors.accentBlue,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$stamps/$required',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalBadge extends StatelessWidget {
  final int rank;
  const _MedalBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final Color bg = rank <= 3
        ? [Colors.amber, Colors.grey.shade400, Colors.brown.shade300][rank - 1]
        : Colors.grey.shade200;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$rank',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: rank <= 3 ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
