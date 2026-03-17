import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

/// Terms and conditions section
class TermsSection extends StatelessWidget {
  final String timeLeft;
  final String location;
  final String dealType;
  final int totalRequired;

  const TermsSection({
    super.key,
    required this.timeLeft,
    required this.location,
    required this.dealType,
    required this.totalRequired,
  });

  Widget _buildConditionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conditions',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConditionItem('Valide jusqu\'au: $timeLeft'),
              _buildConditionItem('Disponible au: $location'),
              if (dealType == 'Loyalty')
                _buildConditionItem(
                    '$totalRequired timbres requis pour la récompense'),
              _buildConditionItem('Non cumulable avec d\'autres offres'),
              _buildConditionItem('Présentation de l\'application requise'),
            ],
          ),
        ),
      ],
    );
  }
}
