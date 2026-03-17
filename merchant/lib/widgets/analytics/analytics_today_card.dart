import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';

/// Gradient card showing today's stamp/enrollment/pending-reward activity.
class AnalyticsTodayCard extends StatelessWidget {
  final int stampsToday;
  final int enrollmentsToday;
  final int pendingRewards;

  const AnalyticsTodayCard({
    super.key,
    required this.stampsToday,
    required this.enrollmentsToday,
    required this.pendingRewards,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activité d\'aujourd\'hui',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActivityStat(
                icon: Icons.confirmation_number_outlined,
                value: stampsToday,
                label: 'Timbres',
              ),
              _DividerLine(),
              _ActivityStat(
                icon: Icons.person_add_alt_1_outlined,
                value: enrollmentsToday,
                label: 'Inscriptions',
              ),
              _DividerLine(),
              _ActivityStat(
                icon: Icons.card_giftcard_outlined,
                value: pendingRewards,
                label: 'Récompenses\nen attente',
                highlight: pendingRewards > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.white24);
  }
}

class _ActivityStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final bool highlight;

  const _ActivityStat({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: highlight ? Colors.amber : Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: highlight ? Colors.amber : Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, height: 1.2),
        ),
      ],
    );
  }
}
