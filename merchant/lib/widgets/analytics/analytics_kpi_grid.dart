import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';

/// Single KPI metric card (icon + big number + label).
class AnalyticsKpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const AnalyticsKpiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoalText,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// 2-column grid of KPI cards for the analytics overview.
class AnalyticsKpiGrid extends StatelessWidget {
  final int totalClients;
  final int totalStamps;
  final int totalRewards;
  final int activeMembers;
  final int totalDealViews;
  final int totalDealParticipants;

  const AnalyticsKpiGrid({
    super.key,
    required this.totalClients,
    required this.totalStamps,
    required this.totalRewards,
    required this.activeMembers,
    required this.totalDealViews,
    required this.totalDealParticipants,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnalyticsKpiCard(
                icon: Icons.people,
                label: 'Clients inscrits',
                value: totalClients,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsKpiCard(
                icon: Icons.confirmation_number,
                label: 'Timbres accordés',
                value: totalStamps,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnalyticsKpiCard(
                icon: Icons.redeem,
                label: 'Récompenses remises',
                value: totalRewards,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsKpiCard(
                icon: Icons.person,
                label: 'Membres actifs',
                value: activeMembers,
                color: AppColors.urgencyOrange,
              ),
            ),
          ],
        ),
        if (totalDealViews > 0 || totalDealParticipants > 0) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnalyticsKpiCard(
                  icon: Icons.visibility,
                  label: 'Vues promotions',
                  value: totalDealViews,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnalyticsKpiCard(
                  icon: Icons.how_to_reg,
                  label: 'Inscrits promo',
                  value: totalDealParticipants,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
