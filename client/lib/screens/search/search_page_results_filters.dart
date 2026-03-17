part of '../search_page.dart';

extension _SearchPageResultsFilters on _SearchPageState {
  Widget _buildActiveFilters(SearchFilter filter) {
    final filters = <String>[];

    if (filter.category != ShopCategory.all) {
      filters.add(filter.category.displayName);
    }
    if (filter.offerType != OfferType.all) {
      filters.add(filter.offerType.displayName);
    }
    if (filter.distance != DistanceRange.all) {
      filters.add(filter.distance.displayName);
    }

    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.white,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filters
            .map(
              (filterName) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen, width: 1),
                ),
                child: Text(
                  filterName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
