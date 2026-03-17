part of '../enrollment_details_screen.dart';

extension _EnrollmentDetailsStatus on _EnrollmentDetailsScreenState {
  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _enrollment.progress.clamp(0.0, 1.0);
    final statusColor = _getStatusColor();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoalText,
              ),
            ),
            Text(
              '${_enrollment.stampsCollected}/${_enrollment.stampsRequired}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    if (_enrollment.isRedeemed) return 'Récompense remise';
    switch (_enrollment.rewardStatus) {
      case RewardRequestStatus.requested:
        return 'Demande en attente';
      case RewardRequestStatus.approved:
        return 'Demande approuvée';
      case RewardRequestStatus.rejected:
        return 'Demande rejetée';
      default:
        break;
    }
    if (_enrollment.canRequestReward) return 'Carte complète';
    return 'Programme actif';
  }

  Color _getStatusColor() {
    if (_enrollment.isRedeemed) return Colors.grey;
    switch (_enrollment.rewardStatus) {
      case RewardRequestStatus.requested:
        return AppColors.urgencyOrange;
      case RewardRequestStatus.approved:
        return AppColors.primaryGreen;
      case RewardRequestStatus.rejected:
        return Colors.red.shade400;
      default:
        break;
    }
    if (_enrollment.canRequestReward) return AppColors.primaryGreen;
    return AppColors.accentBlue;
  }

  IconData _getStatusIcon() {
    if (_enrollment.isRedeemed) return Icons.check_circle;
    switch (_enrollment.rewardStatus) {
      case RewardRequestStatus.requested:
        return Icons.pending_outlined;
      case RewardRequestStatus.approved:
        return Icons.check_circle_outline;
      case RewardRequestStatus.rejected:
        return Icons.cancel_outlined;
      default:
        break;
    }
    if (_enrollment.canRequestReward) return Icons.card_giftcard;
    return Icons.loyalty;
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Aujourd\'hui';
    if (difference.inDays == 1) return 'Hier';
    if (difference.inDays < 7) return 'Il y a ${difference.inDays}j';
    if (difference.inDays < 30) {
      return 'Il y a ${(difference.inDays / 7).floor()}sem';
    }
    return 'Il y a ${(difference.inDays / 30).floor()}mois';
  }
}
