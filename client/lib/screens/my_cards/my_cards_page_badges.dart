part of '../my_cards_page.dart';

extension _MyCardsPageBadges on _MyCardsPageState {
  Widget _buildStatusBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String dealType) {
    Color badgeColor;
    String badgeLabel;
    IconData badgeIcon;

    switch (dealType) {
      case 'Flash Sale':
        badgeColor = AppColors.urgencyOrange;
        badgeLabel = 'Flash';
        badgeIcon = Icons.flash_on;
        break;
      case 'Deal':
        badgeColor = Colors.blue.shade600;
        badgeLabel = 'Offre';
        badgeIcon = Icons.local_offer;
        break;
      case 'Loyalty':
        badgeColor = AppColors.primaryGreen;
        badgeLabel = 'Fidelite';
        badgeIcon = Icons.card_giftcard;
        break;
      case 'Flyer':
        badgeColor = Colors.purple.shade600;
        badgeLabel = 'Prospectus';
        badgeIcon = Icons.article_outlined;
        break;
      default:
        badgeColor = Colors.grey;
        badgeLabel = dealType;
        badgeIcon = Icons.label;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeLabel,
            style: GoogleFonts.poppins(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
