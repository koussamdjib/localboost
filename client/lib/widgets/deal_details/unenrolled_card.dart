import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

/// Gray card shown when user is not enrolled in loyalty program
class UnenrolledCard extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onEnroll;

  const UnenrolledCard({
    super.key,
    required this.isLoading,
    this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.loyalty_outlined,
                color: AppColors.primaryGreen,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Programme de fidélité',
                  style: GoogleFonts.poppins(
                    color: AppColors.charcoalText,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Inscrivez-vous pour commencer à collecter des timbres et obtenir votre récompense!',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onEnroll,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_circle_outline, size: 22),
              label: Text(
                isLoading ? 'Inscription...' : 'S\'inscrire maintenant',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
