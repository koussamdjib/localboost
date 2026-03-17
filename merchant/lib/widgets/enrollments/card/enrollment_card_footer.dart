part of '../enrollment_card.dart';

extension _EnrollmentCardFooter on EnrollmentCard {
  Widget _buildFooter() {
    return Row(
      children: [
        Icon(Icons.history, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          enrollment.lastStampAt != null
              ? 'Dernier timbre: ${_getLastStampText()}'
              : 'Aucun timbre',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
        const Spacer(),
        if (!enrollment.isRedeemed &&
            enrollment.rewardStatus == RewardRequestStatus.approved &&
            onApproveRedemption != null)
          TextButton.icon(
            onPressed: onApproveRedemption,
            icon: const Icon(Icons.redeem, size: 18),
            label: const Text('Fulfiller'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          )
        else if (!enrollment.isRedeemed &&
            enrollment.rewardStatus == RewardRequestStatus.requested &&
            onApproveRedemption != null)
          TextButton.icon(
            onPressed: onApproveRedemption,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Approuver'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.urgencyOrange,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          )
        else
          Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
      ],
    );
  }
}
