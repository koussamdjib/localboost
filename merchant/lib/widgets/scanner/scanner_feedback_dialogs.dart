import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

part 'feedback/scanner_feedback_dialogs_stamp.dart';
part 'feedback/scanner_feedback_dialogs_redemption.dart';
part 'feedback/scanner_feedback_dialogs_error.dart';

/// Dialog helpers for scanner feedback
class ScannerFeedbackDialogs {
  /// Show success dialog after adding stamp
  static Future<void> showStampSuccess({
    required BuildContext context,
    required String shopName,
    required int newStampCount,
    required int totalRequired,
  }) =>
      _showStampSuccessImpl(
        context: context,
        shopName: shopName,
        newStampCount: newStampCount,
        totalRequired: totalRequired,
      );

  /// Show success dialog after redeeming reward
  static Future<void> showRedemptionSuccess({
    required BuildContext context,
    required String shopName,
  }) =>
      _showRedemptionSuccessImpl(context: context, shopName: shopName);

  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    _showErrorImpl(context, message);
  }

  /// Show confirmation when a stamp is queued for offline sync
  static Future<void> showOfflineStampQueued({
    required BuildContext context,
    required String shopName,
  }) =>
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.cloud_off, color: Colors.orange, size: 40),
          title: Text(
            'Timbre mis en file',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Pas de connexion. Le timbre pour $shopName sera envoyé automatiquement dès le retour du réseau.',
            style: GoogleFonts.poppins(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
}
