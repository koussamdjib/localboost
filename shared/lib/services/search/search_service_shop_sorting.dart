part of '../search_service.dart';

List<Shop> _sortShops(
  List<Shop> shops,
  SortOption sortBy,
  LatLng? userLocation,
) {
  switch (sortBy) {
    case SortOption.nearest:
      if (userLocation != null) {
        shops.sort((a, b) {
          final distA = _calculateDistance(
            userLocation,
            LatLng(a.latitude, a.longitude),
          );
          final distB = _calculateDistance(
            userLocation,
            LatLng(b.latitude, b.longitude),
          );
          return distA.compareTo(distB);
        });
      }
      break;

    case SortOption.newest:
      // Sort flash sales first, then others
      shops.sort((a, b) {
        if (a.dealType == 'Flash Sale' && b.dealType != 'Flash Sale') {
          return -1;
        }
        if (a.dealType != 'Flash Sale' && b.dealType == 'Flash Sale') {
          return 1;
        }
        return 0;
      });
      break;

    case SortOption.expiringSoon:
      // Sort by time left (Flash Sales first)
      shops.sort((a, b) {
        if (a.dealType == 'Flash Sale' && b.dealType != 'Flash Sale') {
          return -1;
        }
        if (a.dealType != 'Flash Sale' && b.dealType == 'Flash Sale') {
          return 1;
        }
        return _parseTimeLeft(a.timeLeft).compareTo(_parseTimeLeft(b.timeLeft));
      });
      break;

    case SortOption.mostStamps:
      shops.sort((a, b) => b.stamps.compareTo(a.stamps));
      break;

    case SortOption.alphabetical:
      shops.sort((a, b) => a.name.compareTo(b.name));
      break;
  }

  return shops;
}

/// Calculate distance between two coordinates in kilometers
double _calculateDistance(LatLng from, LatLng to) {
  const Distance distance = Distance();
  return distance.as(LengthUnit.Kilometer, from, to);
}

/// Parse time left string to hours for comparison
int _parseTimeLeft(String timeLeft) {
  final hoursMatch = RegExp(r'(\d+)h').firstMatch(timeLeft);
  if (hoursMatch != null) {
    return int.parse(hoursMatch.group(1)!);
  }

  final daysMatch = RegExp(r'(\d+)\s*days?').firstMatch(timeLeft);
  if (daysMatch != null) {
    return int.parse(daysMatch.group(1)!) * 24;
  }

  // Default: assume 30 days for "Loyalty"
  return 30 * 24;
}
