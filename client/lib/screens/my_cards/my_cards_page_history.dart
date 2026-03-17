part of '../my_cards_page.dart';

extension _MyCardsPageHistory on _MyCardsPageState {
  Widget _buildStampHistory(List<dynamic> history) {
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Text(
                'Aucun historique disponible',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historique des timbres',
            style: GoogleFonts.poppins(
              color: AppColors.charcoalText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...history.take(10).map((item) => _buildHistoryItem(item)),
          if (history.length > 10) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Et ${history.length - 10} autre${history.length - 10 > 1 ? 's' : ''}...',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
