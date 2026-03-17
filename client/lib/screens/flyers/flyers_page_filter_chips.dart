part of '../flyers_page.dart';

extension _FlyersPageFilterChips on _FlyersPageState {
  Widget _buildCategoryChip(FlyerCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _updateSelectedCategory(category, selected),
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? AppColors.white : AppColors.charcoalText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primaryGreen,
      checkmarkColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTypeChip(FlyerType? type, String label) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _updateSelectedType(type, selected),
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? AppColors.white : AppColors.charcoalText,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.grey.shade200,
      selectedColor: AppColors.accentBlue,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
