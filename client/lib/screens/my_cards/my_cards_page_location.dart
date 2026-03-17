part of '../my_cards_page.dart';

extension _MyCardsPageLocation on _MyCardsPageState {
  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Localisation requise'),
              content: const Text(
                'L\'accès à la localisation est désactivé définitivement. '
                'Veuillez l\'activer dans les paramètres de l\'application.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Geolocator.openAppSettings();
                  },
                  child: const Text('Ouvrir les paramètres'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Fast initial fix.
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null && mounted) {
          _setCurrentPosition(LatLng(last.latitude, last.longitude));
        }
      } catch (_) {}

      // Accurate first fix.
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (mounted) _setCurrentPosition(LatLng(pos.latitude, pos.longitude));
      } catch (_) {}

      // Continuous stream (20 m minimum displacement).
      // AndroidSettings is Android-only; use base LocationSettings on web/Windows.
      final LocationSettings settings =
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
              ? AndroidSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: 20,
                  intervalDuration: const Duration(seconds: 5),
                )
              : const LocationSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: 20,
                );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(
        (pos) {
          if (mounted) _setCurrentPosition(LatLng(pos.latitude, pos.longitude));
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {
      // Keep location as null when GPS is unavailable.
    }
  }

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
