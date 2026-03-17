part of '../search_page.dart';

extension _SearchPageNoResults on _SearchPageState {
  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoalText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez d\'ajuster vos filtres\nou de rechercher autre chose',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                context.read<SearchProvider>().resetAdvancedFilters();
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'Réinitialiser les filtres',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
