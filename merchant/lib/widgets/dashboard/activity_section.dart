import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

/// Activity section showing aggregate stats
class ActivitySection extends StatelessWidget {
  final int totalStampsGranted;
  final int totalRedemptions;

  const ActivitySection({
    super.key,
    required this.totalStampsGranted,
    required this.totalRedemptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activité récente',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoalText,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGreen.withValues(alpha: 0.04),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _ActivityRow(
                icon: Icons.add_circle,
                iconColor: AppColors.primaryGreen,
                label: 'Timbres accordés',
                value: totalStampsGranted.toString(),
              ),
              
              const SizedBox(height: 16),
              Divider(color: AppColors.primaryGreen.withValues(alpha: 0.1), height: 1),
              const SizedBox(height: 16),
              
              _ActivityRow(
                icon: Icons.redeem,
                iconColor: AppColors.successGreen,
                label: 'Récompenses utilisées',
                value: totalRedemptions.toString(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual activity row
class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _ActivityRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 88, minWidth: 36),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoalText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
