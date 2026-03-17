part of '../scanner_action_buttons.dart';

extension _ScannerActionButtonsPrimaryHelpers on ScannerActionButtons {
  VoidCallback _getPrimaryCallback(ScannerAction action) {
    switch (action) {
      case ScannerAction.addStamp:
        return onAddStamp;
      case ScannerAction.approveReward:
        return onApproveReward;
      case ScannerAction.fulfillReward:
        return onFulfillReward;
      case ScannerAction.none:
        return () {};
    }
  }

  Color _getPrimaryColor(ScannerAction action) {
    switch (action) {
      case ScannerAction.addStamp:
        return AppColors.primaryGreen;
      case ScannerAction.approveReward:
        return AppColors.urgencyOrange;
      case ScannerAction.fulfillReward:
        return AppColors.successGreen;
      case ScannerAction.none:
        return Colors.grey;
    }
  }

  IconData _getPrimaryIcon(ScannerAction action) {
    switch (action) {
      case ScannerAction.addStamp:
        return Icons.add_circle;
      case ScannerAction.approveReward:
        return Icons.check_circle_outline;
      case ScannerAction.fulfillReward:
        return Icons.redeem;
      case ScannerAction.none:
        return Icons.block;
    }
  }
}
