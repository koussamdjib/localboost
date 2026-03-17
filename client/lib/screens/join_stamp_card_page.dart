import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_client/screens/my_card_detail_page.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';

/// Dedicated page for joining a loyalty stamp-card program.
/// Separates the "view card" action (DealDetailsPage) from the "join" action.
class JoinStampCardPage extends StatefulWidget {
  final Shop shop;

  const JoinStampCardPage({super.key, required this.shop});

  @override
  State<JoinStampCardPage> createState() => _JoinStampCardPageState();
}

class _JoinStampCardPageState extends State<JoinStampCardPage> {
  bool _isJoining = false;

  Shop get shop => widget.shop;

  Future<void> _join() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    setState(() => _isJoining = true);
    try {
      final enrollment = context.read<EnrollmentProvider>();
      await enrollment.enroll(
        userId: auth.user!.id,
        shopId: shop.id,
        shopName: shop.name,
        stampsRequired: shop.totalRequired,
        loyaltyProgramId: shop.loyaltyProgramId,
      );
      if (!mounted) return;
      await enrollment.loadEnrollments(auth.user!.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Inscrit chez ${shop.name} !',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );

      // Find the enrollment that was just created and go to card detail.
      final newEnrollment = enrollment.enrollments
          .where((e) => e.loyaltyProgramId == shop.loyaltyProgramId)
          .firstOrNull;

      if (mounted) {
        if (newEnrollment != null) {
          // Replace this page with the card detail page.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MyCardDetailPage(shop: shop),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.charcoalText),
        title: Text(
          'Rejoindre le programme',
          style: GoogleFonts.poppins(
              color: AppColors.charcoalText,
              fontWeight: FontWeight.w700,
              fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProgramCard(),
            const SizedBox(height: 28),
            _buildBenefitsCard(),
            const SizedBox(height: 32),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: shop.logoUrl.isNotEmpty
                  ? Image.network(shop.logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _logoFallback())
                  : _logoFallback(),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            shop.name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Programme de fidélité',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          // Stamp dots preview
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              shop.totalRequired.clamp(1, 10),
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                ),
              ),
            ),
          ),
          if (shop.totalRequired > 10)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+ ${shop.totalRequired - 10} autres',
                style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _logoFallback() {
    return Center(
      child: Text(
        shop.name.isNotEmpty ? shop.name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
            color: AppColors.primaryGreen,
            fontSize: 28,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comment ça marche',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.charcoalText,
                fontSize: 15),
          ),
          const SizedBox(height: 16),
          _step('1', 'Faites scanner votre QR code à chaque visite',
              Icons.qr_code_2),
          const SizedBox(height: 12),
          _step('2',
              'Collectez ${shop.totalRequired} timbres pour débloquer votre récompense',
              Icons.local_activity),
          const SizedBox(height: 12),
          _step('3', 'Récompense : ${shop.rewardValue}',
              Icons.card_giftcard),
          if (shop.location.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    shop.location,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _step(String num, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, size: 16, color: AppColors.primaryGreen),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.charcoalText),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoggedIn = auth.user != null;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoggedIn && !_isJoining ? _join : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isJoining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(
                    isLoggedIn ? 'Rejoindre le programme' : 'Connectez-vous pour rejoindre',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
