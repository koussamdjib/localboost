part of '../my_cards_page.dart';

extension _MyCardsPageEmptyState on _MyCardsPageState {
  Widget _buildEmptyState() {
    final isFiltered = _selectedFilter != 'Tous';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered ? Icons.filter_list_off : Icons.card_giftcard_outlined,
                size: 64,
                color: AppColors.primaryGreen.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered
                  ? 'Aucune offre ${_selectedFilter.toLowerCase()}'
                  : 'Aucune carte pour l\'instant',
              style: GoogleFonts.poppins(
                color: AppColors.charcoalText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Essayez un autre filtre ou explorez les offres'
                  : 'Visitez un commerce et collectez vos premiers timbres !',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!isFiltered)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.search, size: 18),
                label: Text(
                  'Explorer les offres',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
