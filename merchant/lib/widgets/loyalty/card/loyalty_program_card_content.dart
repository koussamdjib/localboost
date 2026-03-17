part of '../loyalty_program_card.dart';

extension _LoyaltyProgramCardContent on LoyaltyProgramCard {
  Widget _buildStampsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_activity, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(
            '${program.stampsRequired} timbres requis',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.card_giftcard, size: 14, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              program.rewardDescription,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.grey.shade700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      program.description,
      style: GoogleFonts.poppins(
          fontSize: 13, color: Colors.grey.shade700, height: 1.4),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildValidity() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          program.validityStatus,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: program.isExpired ? Colors.red : Colors.grey.shade600,
            fontWeight: program.isExpired ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
