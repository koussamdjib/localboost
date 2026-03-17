part of '../map_view_widget.dart';

extension _MapViewFilterChips on _MapViewWidgetState {
  Widget _buildFilterChips() {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterChip('Tous', OfferType.all, Icons.apps_rounded),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Offres',
              OfferType.deal,
              Icons.local_offer_rounded,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Fidélité',
              OfferType.loyalty,
              Icons.card_giftcard_rounded,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
                'Flash', OfferType.flashSale, Icons.flash_on_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, OfferType type, IconData icon) {
    final isSelected = _selectedFilter == type;
    final style = _chipStyle(type: type, isSelected: isSelected);

    return GestureDetector(
      onTap: () => _selectFilter(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: style.chipColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? style.chipColor : Colors.grey.shade300,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? style.chipColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: style.iconColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: style.textColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _FilterChipStyle _chipStyle({
    required OfferType type,
    required bool isSelected,
  }) {
    if (!isSelected) {
      return _FilterChipStyle(
        chipColor: AppColors.white,
        iconColor: AppColors.charcoalText.withValues(alpha: 0.6),
        textColor: AppColors.charcoalText.withValues(alpha: 0.7),
      );
    }

    switch (type) {
      case OfferType.deal:
        return const _FilterChipStyle(
          chipColor: AppColors.accentBlue,
          iconColor: AppColors.white,
          textColor: AppColors.white,
        );
      case OfferType.loyalty:
        return const _FilterChipStyle(
          chipColor: AppColors.primaryGreen,
          iconColor: AppColors.white,
          textColor: AppColors.white,
        );
      case OfferType.flashSale:
        return const _FilterChipStyle(
          chipColor: AppColors.urgencyOrange,
          iconColor: AppColors.white,
          textColor: AppColors.white,
        );
      default:
        return const _FilterChipStyle(
          chipColor: AppColors.charcoalText,
          iconColor: AppColors.white,
          textColor: AppColors.white,
        );
    }
  }

  void _selectFilter(OfferType type) {
    _setSelectedFilter(type);
  }
}

class _FilterChipStyle {
  final Color chipColor;
  final Color iconColor;
  final Color textColor;

  const _FilterChipStyle({
    required this.chipColor,
    required this.iconColor,
    required this.textColor,
  });
}
