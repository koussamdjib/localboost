import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

/// Description section with dynamic content based on deal type
class DescriptionSection extends StatelessWidget {
  final String dealType;
  final String shopName;
  final String rewardValue;
  final int totalRequired;
  final String timeLeft;

  const DescriptionSection({
    super.key,
    required this.dealType,
    required this.shopName,
    required this.rewardValue,
    required this.totalRequired,
    required this.timeLeft,
  });

  String _getDescription() {
    if (dealType == 'Flash Sale') {
      return 'Profitez de cette offre à durée limitée! $rewardValue vous attend. Dépêchez-vous, cette offre expire dans $timeLeft!';
    } else if (dealType == 'Loyalty') {
      return 'Rejoignez notre programme de fidélité et collectez $totalRequired timbres pour débloquer $rewardValue. Chaque achat vous rapproche de votre récompense!';
    } else {
      return 'Découvrez cette offre exceptionnelle: $rewardValue. Profitez-en dès maintenant chez $shopName.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _getDescription(),
          style: GoogleFonts.poppins(
            color: Colors.grey.shade700,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
