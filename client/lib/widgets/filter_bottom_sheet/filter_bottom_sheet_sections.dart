part of '../filter_bottom_sheet.dart';

extension _FilterBottomSheetSections on _FilterBottomSheetState {
  Widget _buildCategorySection() {
    return _buildEnumSection<ShopCategory>(
      title: 'Catégorie',
      values: ShopCategory.values,
      selectedValue: _filter.category,
      labelBuilder: (category) => category.displayName,
      onSelect: (category) =>
          _updateFilter(_filter.copyWith(category: category)),
    );
  }

  Widget _buildOfferTypeSection() {
    return _buildEnumSection<OfferType>(
      title: 'Type d\'offre',
      values: OfferType.values,
      selectedValue: _filter.offerType,
      labelBuilder: (type) => type.displayName,
      onSelect: (type) => _updateFilter(_filter.copyWith(offerType: type)),
    );
  }

  Widget _buildDistanceSection() {
    return _buildEnumSection<DistanceRange>(
      title: 'Distance',
      values: DistanceRange.values,
      selectedValue: _filter.distance,
      labelBuilder: (distance) => distance.displayName,
      onSelect: (distance) =>
          _updateFilter(_filter.copyWith(distance: distance)),
    );
  }

  Widget _buildSortSection() {
    return _buildEnumSection<SortOption>(
      title: 'Trier par',
      values: SortOption.values,
      selectedValue: _filter.sortBy,
      labelBuilder: (sort) => sort.displayName,
      onSelect: (sort) => _updateFilter(_filter.copyWith(sortBy: sort)),
    );
  }

  Widget _buildEnumSection<T>({
    required String title,
    required List<T> values,
    required T selectedValue,
    required String Function(T value) labelBuilder,
    required ValueChanged<T> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoalText,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (value) => _buildFilterChip(
                  label: labelBuilder(value),
                  isSelected: selectedValue == value,
                  onTap: () => onSelect(value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _updateFilter(SearchFilter updatedFilter) {
    _setFilter(updatedFilter);
  }
}
