import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_client/screens/join_stamp_card_page.dart';
import 'package:localboost_client/widgets/loyalty_card/flippable_loyalty_card.dart';
import 'package:localboost_client/screens/my_card_detail_page.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';

/// "Cartes de Fidélité" tab — loyalty stamp card programs for this enterprise.
class EnterpriseTabStampCards extends StatelessWidget {
  final List<Shop> loyaltyCards;

  const EnterpriseTabStampCards({super.key, required this.loyaltyCards});

  @override
  Widget build(BuildContext context) {
    if (loyaltyCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Aucune carte de fidélité',
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return Consumer<EnrollmentProvider>(
      builder: (context, enrollmentProvider, _) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: loyaltyCards.length,
          itemBuilder: (context, index) {
            final shop = loyaltyCards[index];
            final isEnrolled = shop.enrollmentId != null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: isEnrolled
                  ? _buildEnrolledCard(context, shop)
                  : _buildDiscoveryCard(context, shop, enrollmentProvider),
            );
          },
        );
      },
    );
  }

  Widget _buildEnrolledCard(BuildContext context, Shop shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FlippableLoyaltyCard(shop: shop),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MyCardDetailPage(shop: shop)),
            ),
            icon: const Icon(Icons.open_in_new, size: 14),
            label: Text('Voir ma carte',
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w500)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryCard(
      BuildContext context, Shop shop, EnrollmentProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: shop.logoUrl.isNotEmpty
                    ? Image.network(shop.logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackLogo(shop.name))
                    : _fallbackLogo(shop.name),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '${shop.rewardIcon} ${shop.rewardValue}',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${shop.totalRequired} timbres requis',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JoinStampCardPage(shop: shop),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
              child: const Text('Rejoindre'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackLogo(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
            color: AppColors.primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
