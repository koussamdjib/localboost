part of '../enrollment_card.dart';

extension _EnrollmentCardHelpers on EnrollmentCard {
  String _getStatusText() {
    if (enrollment.isRedeemed) return 'Utilisé';
    switch (enrollment.rewardStatus) {
      case RewardRequestStatus.requested:
        return 'Demande en attente';
      case RewardRequestStatus.approved:
        return 'Demande approuvée';
      case RewardRequestStatus.rejected:
        return 'Demande rejetée';
      default:
        break;
    }
    if (enrollment.canRequestReward) return 'Complet';
    return 'Actif';
  }

  Color _getStatusColor() {
    if (enrollment.isRedeemed) return Colors.grey;
    switch (enrollment.rewardStatus) {
      case RewardRequestStatus.requested:
        return AppColors.urgencyOrange;
      case RewardRequestStatus.approved:
        return AppColors.primaryGreen;
      case RewardRequestStatus.rejected:
        return Colors.red.shade400;
      default:
        break;
    }
    if (enrollment.canRequestReward) return AppColors.primaryGreen;
    return AppColors.accentBlue;
  }

  IconData _getStatusIcon() {
    if (enrollment.isRedeemed) return Icons.check_circle;
    switch (enrollment.rewardStatus) {
      case RewardRequestStatus.requested:
        return Icons.pending_outlined;
      case RewardRequestStatus.approved:
        return Icons.check_circle_outline;
      case RewardRequestStatus.rejected:
        return Icons.cancel_outlined;
      default:
        break;
    }
    if (enrollment.canRequestReward) return Icons.card_giftcard;
    return Icons.loyalty;
  }

  Color _getProgressColor() {
    if (enrollment.canRequestReward) return AppColors.primaryGreen;
    if (enrollment.progress >= 0.5) return AppColors.urgencyOrange;
    return AppColors.accentBlue;
  }

  String _getEnrollmentDate() {
    final formatter = DateFormat('dd MMM yyyy', 'fr_FR');
    return 'Inscrit le ${formatter.format(enrollment.enrolledAt)}';
  }

  String _getLastStampText() {
    if (enrollment.lastStampAt == null) return 'Jamais';

    final now = DateTime.now();
    final difference = now.difference(enrollment.lastStampAt!);

    if (difference.inDays == 0) return 'Aujourd\'hui';
    if (difference.inDays == 1) return 'Hier';
    if (difference.inDays < 7) return 'Il y a ${difference.inDays}j';
    if (difference.inDays < 30) {
      return 'Il y a ${(difference.inDays / 7).floor()}sem';
    }
    return 'Il y a ${(difference.inDays / 30).floor()}mois';
  }
}
