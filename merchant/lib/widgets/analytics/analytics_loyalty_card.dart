import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_merchant/models/loyalty_program.dart';
import 'package:localboost_merchant/widgets/analytics/analytics_section_widgets.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';

/// Card showing loyalty program analytics: enrollments, active members,
/// stamps granted, redemptions, active-rate progress bar.
class AnalyticsLoyaltyCard extends StatelessWidget {
  final LoyaltyProgram program;
  const AnalyticsLoyaltyCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final enrollments = program.enrollmentCount;
    final active = program.activeMembers;
    final stamps = program.totalStampsGranted;
    final redemptions = program.redemptionCount;
    final activePct =
        enrollments > 0 ? (active / enrollments).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  program.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalText,
                  ),
                ),
              ),
              AnalyticsStatusChip(status: program.status.name),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${program.stampsRequired} timbre(s) requis',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AnalyticsStatBadge(icon: Icons.people, value: enrollments, label: 'Inscrits', color: Colors.blue),
              const SizedBox(width: 8),
              AnalyticsStatBadge(icon: Icons.person, value: active, label: 'Actifs', color: Colors.orange),
              const SizedBox(width: 8),
              AnalyticsStatBadge(icon: Icons.add_circle, value: stamps, label: 'Timbres', color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              AnalyticsStatBadge(icon: Icons.redeem, value: redemptions, label: 'Récompenses', color: Colors.purple),
            ],
          ),
          if (enrollments > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Membres actifs : ',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                Text(
                  '${(activePct * 100).toStringAsFixed(0)} %',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: activePct,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
          ],
        ],
      ),
    );
  }
}
