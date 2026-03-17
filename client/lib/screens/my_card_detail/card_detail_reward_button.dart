import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';

/// Large green CTA button that submits a reward redemption request.
class CardDetailRewardButton extends StatefulWidget {
  final Shop shop;
  const CardDetailRewardButton({super.key, required this.shop});

  @override
  State<CardDetailRewardButton> createState() => _CardDetailRewardButtonState();
}

class _CardDetailRewardButtonState extends State<CardDetailRewardButton> {
  bool _loading = false;

  Future<void> _requestReward() async {
    if (widget.shop.enrollmentId == null) return;
    setState(() => _loading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final enrollmentProvider = context.read<EnrollmentProvider>();
      await enrollmentProvider.requestReward(widget.shop.enrollmentId!);
      if (mounted) {
        if (authProvider.user != null) {
          await enrollmentProvider.loadEnrollments(authProvider.user!.id);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 Demande envoyée ! Le marchand va traiter votre récompense.',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _loading ? null : _requestReward,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          icon: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.card_giftcard_outlined),
          label: Text(
            _loading ? 'Envoi en cours...' : 'Demander ma récompense',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
