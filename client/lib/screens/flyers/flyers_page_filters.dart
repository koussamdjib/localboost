part of '../flyers_page.dart';

extension _FlyersPageFilters on _FlyersPageState {
  Widget _buildSortBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 20, color: AppColors.charcoalText),
          const SizedBox(width: 8),
          Text(
            'Trier par:',
            style: GoogleFonts.poppins(
              color: AppColors.charcoalText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Plus récent'),
                  const SizedBox(width: 8),
                  _buildSortChip('Plus proche'),
                  const SizedBox(width: 8),
                  _buildSortChip('A-Z'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label) {
    final isSelected = _selectedSort == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _updateSelectedSort(label),
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? AppColors.white : AppColors.charcoalText,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primaryGreen,
      checkmarkColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
