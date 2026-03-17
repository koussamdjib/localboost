import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_client/screens/qr_code_screen.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:provider/provider.dart';
import 'package:localboost_client/screens/my_card_detail/card_detail_info_cards.dart';
import 'package:localboost_client/screens/my_card_detail/card_detail_progress_ring.dart';
import 'package:localboost_client/screens/my_card_detail/card_detail_reward_button.dart';
import 'package:localboost_client/screens/my_card_detail/card_detail_stamp_history.dart';

/// Full-screen loyalty card detail page.
class MyCardDetailPage extends StatelessWidget {
  final Shop shop;

  const MyCardDetailPage({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                CardDetailProgressRing(shop: shop),
                const SizedBox(height: 12),
                CardDetailRewardInfo(shop: shop),
                if (shop.history != null && shop.history!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  CardDetailStampHistory(shop: shop),
                ],
                const SizedBox(height: 12),
                CardDetailShopInfo(shop: shop),
                if (shop.enrollmentId != null) ...[
                  const SizedBox(height: 12),
                  _buildQrButton(context),
                ],
                if (shop.isComplete && !shop.isRedeemed) ...[
                  const SizedBox(height: 16),
                  CardDetailRewardButton(shop: shop),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            final enrollmentId = shop.enrollmentId;
            if (enrollmentId == null) return;
            final provider = context.read<EnrollmentProvider>();
            final enrollment = provider.enrollments
                .where((e) => e.id == enrollmentId)
                .firstOrNull;
            if (enrollment == null) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => QRCodeScreen(enrollment: enrollment),
              ),
            );
          },
          icon: const Icon(Icons.qr_code_2, color: AppColors.primaryGreen),
          label: const Text(
            'Montrer mon QR',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryGreen),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primaryGreen,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      title: Text(
        shop.name,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: shop.imageUrl.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    shop.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.primaryGreen),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              )
            : Container(color: AppColors.primaryGreen),
      ),
      expandedHeight: 200,
    );
  }
}
