part of '../search_page.dart';

extension _SearchPageLocation on _SearchPageState {
  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationLoadingDone();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setLocationLoadingDone();
        return;
      }

      // Fast initial fix.
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null && mounted) {
          _setLocationSuccess(LatLng(last.latitude, last.longitude));
        }
      } catch (_) {}

      // Accurate first fix.
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        if (mounted) _setLocationSuccess(LatLng(pos.latitude, pos.longitude));
      } catch (_) {
        _setLocationLoadingDone();
      }

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
          if (mounted) _setLocationSuccess(LatLng(pos.latitude, pos.longitude));
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {
      _setLocationLoadingDone();
    }
  }
}
