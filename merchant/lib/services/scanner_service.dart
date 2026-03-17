import 'package:localboost_shared/models/enrollment.dart';

/// Service for handling QR code scanning and validation in merchant scanner
class ScannerService {
  /// Parse enrollment QR token (UUID format).
  /// Returns the token string or null if blank.
  static String? parseEnrollmentToken(String qrCode) {
    final trimmed = qrCode.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Validate that the scanned code is a non-empty string (UUID check is server-side).
  static bool isValidQrCode(String qrCode) {
    final token = parseEnrollmentToken(qrCode);
    return token != null && token.isNotEmpty;
  }

  /// Check if enrollment can accept a stamp
  /// Returns error message if invalid, null if valid
  static String? validateStampEligibility(Enrollment enrollment) {
    if (enrollment.isRedeemed) {
      return 'Ce programme a déjà été utilisé';
    }

    if (enrollment.rewardStatus == RewardRequestStatus.requested) {
      return 'Une demande est en attente. Approuvez-la avant toute action.';
    }

    if (enrollment.rewardStatus == RewardRequestStatus.approved) {
      return 'Demande approuvée. Utilisez la validation finale de récompense.';
    }
    
    if (enrollment.stampsCollected >= enrollment.stampsRequired) {
      return 'Tous les timbres sont déjà collectés. Utilisez la récompense.';
    }
    
    return null; // Valid
  }

  /// Check if enrollment can approve a pending request.
  static String? validateApprovalEligibility(Enrollment enrollment) {
    if (enrollment.isRedeemed) {
      return 'Cette récompense a déjà été utilisée';
    }

    if (enrollment.rewardRequestId == null ||
        enrollment.rewardStatus != RewardRequestStatus.requested) {
      return 'Aucune demande en attente à approuver';
    }

    return null;
  }

  /// Check if enrollment can fulfill an approved request.
  static String? validateFulfillmentEligibility(Enrollment enrollment) {
    if (enrollment.isRedeemed) {
      return 'Cette récompense a déjà été utilisée';
    }

    if (enrollment.rewardRequestId == null ||
        enrollment.rewardStatus != RewardRequestStatus.approved) {
      return 'La demande doit être approuvée avant validation finale';
    }

    return null;
  }

  /// Calculate time since last stamp
  static String? getTimeSinceLastStamp(Enrollment enrollment) {
    if (enrollment.lastStampAt == null) {
      return null;
    }
    
    final difference = DateTime.now().difference(enrollment.lastStampAt!);
    
    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a ${weeks}sem';
    }
  }

  /// Format enrollment progress for display
  static String formatProgress(Enrollment enrollment) {
    return '${enrollment.stampsCollected}/${enrollment.stampsRequired} timbres';
  }

  /// Get status message for enrollment
  static String getStatusMessage(Enrollment enrollment) {
    if (enrollment.isRedeemed) {
      return 'Récompense utilisée';
    }

    if (enrollment.rewardStatus == RewardRequestStatus.requested) {
      return 'Demande en attente d\'approbation';
    }

    if (enrollment.rewardStatus == RewardRequestStatus.approved) {
      return 'Demande approuvée. Prêt pour validation finale';
    }

    if (enrollment.canRequestReward) {
      return 'Carte complète. Le client doit demander sa récompense';
    }

    final remaining = enrollment.stampsRequired - enrollment.stampsCollected;
    return 'Encore $remaining timbre${remaining > 1 ? 's' : ''} nécessaire${remaining > 1 ? 's' : ''}';
  }

  /// Determine primary action for enrollment
  static ScannerAction getPrimaryAction(Enrollment enrollment) {
    if (enrollment.isRedeemed) {
      return ScannerAction.none;
    }

    switch (enrollment.rewardStatus) {
      case RewardRequestStatus.requested:
        return ScannerAction.approveReward;
      case RewardRequestStatus.approved:
        return ScannerAction.fulfillReward;
      default:
        break;
    }

    if (enrollment.canRequestReward) {
      return ScannerAction.none;
    }

    return ScannerAction.addStamp;
  }
}

/// Available actions in scanner
enum ScannerAction {
  addStamp,
  approveReward,
  fulfillReward,
  none,
}

extension ScannerActionExtension on ScannerAction {
  String get label {
    switch (this) {
      case ScannerAction.addStamp:
        return 'Ajouter un timbre';
      case ScannerAction.approveReward:
        return 'Approuver la demande';
      case ScannerAction.fulfillReward:
        return 'Valider la récompense';
      case ScannerAction.none:
        return 'Aucune action';
    }
  }
}
