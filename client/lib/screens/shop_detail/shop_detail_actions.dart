import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_client/screens/deal_details_page.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop.dart';

/// Time-left info row shown when [shop.timeLeft] is non-empty.
class ShopDetailInfoRow extends StatelessWidget {
  final Shop shop;

  const ShopDetailInfoRow({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    if (shop.timeLeft.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time,
              size: 18, color: AppColors.urgencyOrange),
          const SizedBox(width: 10),
          Text(
            shop.timeLeft,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.charcoalText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary + secondary CTA buttons: "Voir tous les détails" and optional
/// enroll button.
class ShopDetailActions extends StatelessWidget {
  final Shop shop;
  final bool isEnrolled;
  final bool isEnrolling;
  final VoidCallback onEnroll;

  const ShopDetailActions({
    super.key,
    required this.shop,
    required this.isEnrolled,
    required this.isEnrolling,
    required this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DealDetailsPage(shop: shop)),
                );
              },
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(
                'Voir tous les détails',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          if (!isEnrolled) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: isEnrolling ? null : onEnroll,
                icon: isEnrolling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                      )
                    : const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: Text(
                  isEnrolling ? 'Inscription...' : 'S\'inscrire maintenant',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(
                      color: AppColors.primaryGreen, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
