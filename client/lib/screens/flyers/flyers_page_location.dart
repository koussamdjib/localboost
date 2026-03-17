part of '../flyers_page.dart';

extension _FlyersPageLocation on _FlyersPageState {
  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

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
      // Ignore GPS errors and keep fallback distance behavior.
    }
  }

  double _getDistance(Flyer flyer) {
    final origin = _currentPosition ?? const LatLng(11.5721, 43.1456);
    return GpsDistanceCalculator.calculateDistance(
      origin,
      LatLng(flyer.latitude, flyer.longitude),
    );
  }
}
