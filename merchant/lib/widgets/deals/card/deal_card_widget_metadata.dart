part of '../deal_card_widget.dart';

extension _DealCardWidgetMetadata on DealCardWidget {
  Widget _buildMetadata() {
    return Row(
      children: [
        _buildMetadataItem(Icons.visibility, '${deal.viewCount}'),
        const SizedBox(width: 12),
        _buildMetadataItem(Icons.people, '${deal.enrollmentCount}'),
        const SizedBox(width: 12),
        _buildMetadataItem(Icons.redeem, '${deal.redemptionCount}'),
        const Spacer(),
        Text(
          deal.timeLeft,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: deal.isExpired ? Colors.red : Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
