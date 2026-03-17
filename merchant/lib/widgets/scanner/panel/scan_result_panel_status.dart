part of '../scan_result_panel.dart';

extension _ScanResultPanelStatus on ScanResultPanel {
  Color _getStatusColor() {
    switch (enrollment.rewardStatus) {
      case RewardRequestStatus.requested:
        return AppColors.urgencyOrange;
      case RewardRequestStatus.approved:
        return AppColors.successGreen;
      default:
        break;
    }

    if (enrollment.canRequestReward) {
      return AppColors.successGreen;
    }

    return AppColors.primaryGreen;
  }

  IconData _getStatusIcon() {
    switch (enrollment.rewardStatus) {
      case RewardRequestStatus.requested:
        return Icons.pending_outlined;
      case RewardRequestStatus.approved:
        return Icons.check_circle_outline;
      default:
        break;
    }

    if (enrollment.canRequestReward) {
      return Icons.star;
    }

    return Icons.loyalty;
  }
}
