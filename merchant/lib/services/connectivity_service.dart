import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps connectivity_plus and exposes an [isOnline] stream + sync helper.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onlineStream => _connectivity.onConnectivityChanged
      .map((results) => _isOnline(results));

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);
}
