part of '../my_cards_page.dart';

extension _MyCardsPageLocation on _MyCardsPageState {
  double _getDistance(Shop shop) {
    final origin = _currentPosition ?? const LatLng(11.5721, 43.1456);
    return GpsDistanceCalculator.calculateDistance(
      origin,
      LatLng(shop.latitude, shop.longitude),
    );
  }

  String _formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}
