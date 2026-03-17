part of '../qr_code_screen.dart';

extension _QrCodeScreenSections on QRCodeScreen {
  Widget _buildBrightnessNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.brightness_high,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Luminosité de l\'écran au maximum',
              style: GoogleFonts.poppins(
                color: AppColors.charcoalText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final qrSize = (constraints.maxWidth * 0.7).clamp(200.0, 280.0);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Builder(
            builder: (context) {
              final qrData = enrollment.qrToken.isNotEmpty
                  ? enrollment.qrToken
                  : enrollment.id;
              return QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: qrSize,
                backgroundColor: AppColors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.charcoalText,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.charcoalText,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInstructions() {
    return Column(
      children: [
        Text(
          'Montrez ceci au commerçant',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'pour recevoir votre timbre',
          style: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserIdBadge() {
    final programLabel = enrollment.loyaltyProgramName != null &&
            enrollment.loyaltyProgramName!.isNotEmpty
        ? enrollment.loyaltyProgramName!
        : enrollment.shopName;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            enrollment.shopName,
            style: GoogleFonts.poppins(
              color: AppColors.charcoalText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          if (programLabel != enrollment.shopName) ...
            [
              const SizedBox(height: 2),
              Text(
                programLabel,
                style: GoogleFonts.poppins(
                  color: AppColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
        ],
      ),
    );
  }
}
