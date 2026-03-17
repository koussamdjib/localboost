import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_merchant/services/scanner_service.dart';

part 'buttons/scanner_action_buttons_primary_helpers.dart';

/// Action buttons for scanner (add stamp, redeem, cancel)
class ScannerActionButtons extends StatelessWidget {
  final Enrollment enrollment;
  final VoidCallback onAddStamp;
  final VoidCallback onApproveReward;
  final VoidCallback onFulfillReward;
  final VoidCallback onCancel;
  final bool isProcessing;

  const ScannerActionButtons({
    super.key,
    required this.enrollment,
    required this.onAddStamp,
    required this.onApproveReward,
    required this.onFulfillReward,
    required this.onCancel,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final primaryAction = ScannerService.getPrimaryAction(enrollment);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary action button
          if (primaryAction != ScannerAction.none)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isProcessing ? null : _getPrimaryCallback(primaryAction),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPrimaryColor(primaryAction),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getPrimaryIcon(primaryAction)),
                    const SizedBox(width: 8),
                    Text(
                      primaryAction.label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Cancel button
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: isProcessing ? null : onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Annuler',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
