part of '../search_page.dart';

extension _SearchPageHistory on _SearchPageState {
  Widget _buildSearchHistory() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final history = searchProvider.searchHistory;

        if (history.isEmpty) {
          return _buildEmptyHistory();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recherches récentes',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalText,
                    ),
                  ),
                  TextButton(
                    onPressed: searchProvider.clearHistory,
                    child: Text(
                      'Effacer tout',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryGreen,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(
                      entry.query,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.grey,
                      onPressed: () {
                        searchProvider.removeFromHistory(entry.id);
                      },
                    ),
                    onTap: () => _performSearch(entry.query),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Commencez votre recherche',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recherchez des commerces, offres ou prospectus',
            style:
                GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
