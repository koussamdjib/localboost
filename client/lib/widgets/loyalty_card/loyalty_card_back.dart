import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Back face of a loyalty card — shows QR code, reward details, and conditions.
class LoyaltyCardBack extends StatelessWidget {
  final Shop shop;
  /// If non-null, the QR code is rendered for scanning by a merchant.
  final Enrollment? enrollment;

  const LoyaltyCardBack({
    super.key,
    required this.shop,
    this.enrollment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildInstruction(),
            const SizedBox(height: 8),
            Expanded(child: _buildQrSection()),
            const SizedBox(height: 8),
            _buildFlipHint(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: shop.logoUrl.isNotEmpty
                ? Image.network(
                    shop.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _logoFallback(),
                  )
                : _logoFallback(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shop.name,
                style: GoogleFonts.poppins(
                  color: AppColors.charcoalText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                shop.location,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (shop.enrollmentId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Inscrit',
              style: GoogleFonts.poppins(
                color: AppColors.primaryGreen,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          _joinBadge(),
      ],
    );
  }

  Widget _logoFallback() {
    return Center(
      child: Text(
        shop.name.isNotEmpty ? shop.name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
          color: AppColors.primaryGreen,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _joinBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Rejoindre',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInstruction() {
    final hasQr = enrollment?.qrToken.isNotEmpty == true;
    if (!hasQr) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.storefront_outlined, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Text(
          'Montrez ce QR au commerçant',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQrSection() {
    final qrToken = enrollment?.qrToken;

    if (qrToken == null || qrToken.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2, size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              shop.enrollmentId != null
                  ? 'QR code non disponible'
                  : 'Rejoignez ce programme\npour obtenir votre QR',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: QrImageView(
          data: qrToken,
          version: QrVersions.auto,
          size: 130,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: AppColors.charcoalText,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: AppColors.charcoalText,
          ),
          errorCorrectionLevel: QrErrorCorrectLevel.M,
        ),
      ),
    );
  }

  Widget _buildFlipHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.flip, size: 12, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          'Appuyer pour voir les timbres',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade400,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
