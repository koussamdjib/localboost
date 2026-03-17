import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_client/screens/shop_detail/shop_detail_actions.dart';
import 'package:localboost_client/screens/shop_detail/shop_detail_header.dart';
import 'package:localboost_client/screens/shop_detail/shop_detail_loyalty_card.dart';

/// Full-screen shop detail page — opened from map marker taps.
class ShopDetailPage extends StatefulWidget {
  final Shop shop;

  const ShopDetailPage({super.key, required this.shop});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  bool _enrolling = false;

  Shop get shop => widget.shop;

  Future<void> _enroll() async {
    setState(() => _enrolling = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final enrollmentProvider = context.read<EnrollmentProvider>();
      if (authProvider.user == null) return;

      await enrollmentProvider.enroll(
        userId: authProvider.user!.id,
        shopId: shop.id,
        shopName: shop.name,
        stampsRequired: shop.totalRequired,
        loyaltyProgramId: shop.loyaltyProgramId,
      );
      if (mounted) {
        await enrollmentProvider.loadEnrollments(authProvider.user!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 Inscrit chez ${shop.name} !',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cross-reference with EnrollmentProvider since API shop objects don't
    // carry enrollmentId. Match by loyaltyProgramId first, then shopId.
    final enrollments = context.watch<EnrollmentProvider>().enrollments;
    final enrollment = enrollments.where((e) {
      if (shop.loyaltyProgramId != null) {
        return e.loyaltyProgramId == shop.loyaltyProgramId;
      }
      return e.shopId == shop.id;
    }).firstOrNull;

    final isEnrolled = enrollment != null;
    final displayShop = enrollment != null
        ? Shop(
            id: shop.id,
            enrollmentId: enrollment.id,
            loyaltyProgramId: shop.loyaltyProgramId,
            name: shop.name,
            stamps: enrollment.stampsCollected,
            totalRequired: enrollment.stampsRequired,
            dealType: shop.dealType,
            timeLeft: shop.timeLeft,
            location: shop.location,
            rewardValue: shop.rewardValue,
            rewardType: shop.rewardType,
            imageUrl: shop.imageUrl,
            logoUrl: shop.logoUrl,
            latitude: shop.latitude,
            longitude: shop.longitude,
          )
        : shop;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: CustomScrollView(
        slivers: [
          ShopDetailHeroAppBar(
            shop: displayShop,
            onBack: () => Navigator.pop(context),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShopDetailHeader(shop: displayShop),
                const SizedBox(height: 12),
                if (displayShop.dealType == 'Loyalty') ...[
                  ShopDetailLoyaltyCard(shop: displayShop, isEnrolled: isEnrolled),
                  const SizedBox(height: 12),
                ],
                ShopDetailInfoRow(shop: displayShop),
                const SizedBox(height: 20),
                ShopDetailActions(
                  shop: displayShop,
                  isEnrolled: isEnrolled,
                  isEnrolling: _enrolling,
                  onEnroll: _enroll,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
