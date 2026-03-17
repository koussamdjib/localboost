import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

part 'camera/scanner_overlay_painter.dart';

/// Camera widget for QR code scanning with overlay
class ScannerCameraWidget extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  final bool isProcessing;

  const ScannerCameraWidget({
    super.key,
    required this.controller,
    required this.onDetect,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera preview
        MobileScanner(
          controller: controller,
          onDetect: onDetect,
        ),

        // Scanning overlay with cutout
        CustomPaint(
          painter: _ScannerOverlayPainter(),
          child: Container(),
        ),

        // Processing overlay
        if (isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Traitement...',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
