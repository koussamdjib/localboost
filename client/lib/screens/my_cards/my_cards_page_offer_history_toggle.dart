part of '../my_cards_page.dart';

extension _MyCardsPageOfferHistoryToggle on _MyCardsPageState {
  Widget _buildCardHistoryToggle(String shopId, bool isExpanded) {
    return InkWell(
      onTap: () => _toggleExpandedCard(shopId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.history, size: 18, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isExpanded
                    ? 'Masquer l\'historique'
                    : 'Voir l\'historique des timbres',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
