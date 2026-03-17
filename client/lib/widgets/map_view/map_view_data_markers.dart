part of '../map_view_widget.dart';

extension _MapViewDataMarkers on _MapViewWidgetState {
  /// Filters the cached shop list locally — no API call, instant on slider change.
  List<Shop> _getLocallyFilteredShops() {
    return _cachedShops.where((shop) {
      if (shop.latitude == 0.0 && shop.longitude == 0.0) return false;
      final dist = GpsDistanceCalculator.calculateDistance(
        widget.currentPosition,
        LatLng(shop.latitude, shop.longitude),
      );
      if (dist > _selectedRadiusKm) return false;
      switch (_selectedFilter) {
        case OfferType.deal:
          return shop.dealType == 'Deal';
        case OfferType.loyalty:
          return shop.dealType == 'Loyalty';
        case OfferType.flashSale:
          return shop.dealType == 'Flash Sale';
        case OfferType.flyer:
          return false;
        case OfferType.all:
          return true;
      }
    }).toList();
  }

  List<Marker> _buildMarkers(List<Shop> filteredShops) {
    final markers = <Marker>[
      Marker(
        point: widget.currentPosition,
        width: 30,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.accentBlue,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlue.withValues(alpha: 0.35),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    ];

    markers.addAll(filteredShops.map((shop) {
      final icon = _markerIconForDealType(shop.dealType);
      final color = _markerColorForDealType(shop.dealType);

      return Marker(
        point: LatLng(shop.latitude, shop.longitude),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => widget.onShopTap(shop),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      );
    }));

    return markers;
  }

  IconData _markerIconForDealType(String dealType) {
    switch (dealType) {
      case 'Loyalty':
        return Icons.card_giftcard_rounded;
      case 'Flash Sale':
        return Icons.flash_on_rounded;
      case 'Deal':
        return Icons.local_offer_rounded;
      default:
        return Icons.store_rounded;
    }
  }

  Color _markerColorForDealType(String dealType) {
    switch (dealType) {
      case 'Loyalty':
        return AppColors.primaryGreen;
      case 'Flash Sale':
        return AppColors.urgencyOrange;
      case 'Deal':
        return AppColors.accentBlue;
      default:
        return Colors.grey;
    }
  }
}
