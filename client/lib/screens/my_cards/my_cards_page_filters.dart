part of '../my_cards_page.dart';

extension _MyCardsPageFilters on _MyCardsPageState {
  Widget _buildFilterChips() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tous', Icons.grid_view),
            const SizedBox(width: 8),
            _buildFilterChip('Actifs', Icons.play_circle_outline),
            const SizedBox(width: 8),
            _buildFilterChip('Complétés', Icons.celebration),
            const SizedBox(width: 8),
            _buildFilterChip('Utilisés', Icons.check_circle_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      color: AppColors.lightGray,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.sort, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'Trier par:',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<String>(
                value: _selectedSort,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                style: GoogleFonts.poppins(
                  color: AppColors.charcoalText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                items: ['Défaut', 'A-Z', 'Plus proche']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    _updateSelectedSort(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => _updateSelectedFilter(label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.lightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? AppColors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
