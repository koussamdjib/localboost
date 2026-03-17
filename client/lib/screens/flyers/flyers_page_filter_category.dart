part of '../flyers_page.dart';

extension _FlyersPageFilterCategory on _FlyersPageState {
  Widget _buildCategoryFilter() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catégories:',
            style: GoogleFonts.poppins(
              color: AppColors.charcoalText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(null, 'Tous'),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  FlyerCategory.supermarket,
                  FlyerCategory.supermarket.displayName,
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  FlyerCategory.electronics,
                  FlyerCategory.electronics.displayName,
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  FlyerCategory.pharmacy,
                  FlyerCategory.pharmacy.displayName,
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  FlyerCategory.bakery,
                  FlyerCategory.bakery.displayName,
                ),
                const SizedBox(width: 8),
                _buildCategoryChip(
                  FlyerCategory.sports,
                  FlyerCategory.sports.displayName,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Type:',
                style: GoogleFonts.poppins(
                  color: AppColors.charcoalText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              _buildTypeChip(null, 'Tous'),
              const SizedBox(width: 8),
              _buildTypeChip(FlyerType.image, 'Image'),
              const SizedBox(width: 8),
              _buildTypeChip(FlyerType.pdf, 'PDF'),
            ],
          ),
        ],
      ),
    );
  }
}
