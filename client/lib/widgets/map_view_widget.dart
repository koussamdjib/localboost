import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/core/utils/distance_calculator.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/models/search_filter.dart';
import 'package:localboost_shared/services/search_service.dart';

part 'map_view/map_view_layout.dart';
part 'map_view/map_view_data_markers.dart';
part 'map_view/map_view_filter_chips.dart';
part 'map_view/map_view_badges_buttons.dart';

class MapViewWidget extends StatefulWidget {
  final LatLng currentPosition;
  final MapController mapController;
  final Function(Shop) onShopTap;

  const MapViewWidget({
    super.key,
    required this.currentPosition,
    required this.mapController,
    required this.onShopTap,
  });

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  OfferType _selectedFilter = OfferType.all;
  double _selectedRadiusKm = 5.0;

  // Location name: city and quarter stored separately for expandable badge.
  String? _cityName;
  String? _quarterName;
  bool _isLoadingLocationName = false;
  bool _locationExpanded = false;

  // Shop cache — filled once per filter/position change; slider filters locally.
  List<Shop> _cachedShops = [];
  bool _isFetchingShops = false;

  @override
  void initState() {
    super.initState();
    _fetchLocationName(widget.currentPosition);
    _fetchAndCacheShops();
  }

  Future<void> _fetchAndCacheShops() async {
    if (_isFetchingShops) return;
    if (mounted) setState(() => _isFetchingShops = true);
    try {
      final shops = await SearchService.searchShopsAsync(
        filter: SearchFilter(
          offerType: _selectedFilter,
          sortBy: SortOption.nearest,
        ),
        userLocation: widget.currentPosition,
      );
      if (mounted) {
        setState(() {
          _cachedShops = shops;
          _isFetchingShops = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFetchingShops = false);
    }
  }

  Future<void> _fetchLocationName(LatLng position) async {
    if (_isLoadingLocationName) return;
    if (mounted) setState(() => _isLoadingLocationName = true);
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'format': 'json',
          'lat': '${position.latitude}',
          'lon': '${position.longitude}',
          'zoom': '14',
        },
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'LocalBoost/1.0'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        final quarter = address?['neighbourhood'] as String? ??
            address?['suburb'] as String? ??
            address?['quarter'] as String? ??
            address?['city_district'] as String?;
        final city = address?['city'] as String? ??
            address?['town'] as String? ??
            address?['village'] as String?;
        if (mounted) {
          setState(() {
            _quarterName = quarter;
            _cityName = city;
            _isLoadingLocationName = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingLocationName = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocationName = false);
    }
  }

  bool _hasPositionChanged(LatLng before, LatLng after) {
    const epsilon = 0.00001;
    return (before.latitude - after.latitude).abs() > epsilon ||
        (before.longitude - after.longitude).abs() > epsilon;
  }

  @override
  void didUpdateWidget(covariant MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_hasPositionChanged(oldWidget.currentPosition, widget.currentPosition)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.mapController.move(widget.currentPosition, 14);
      });
      _fetchLocationName(widget.currentPosition);
      _fetchAndCacheShops();
    }
  }

  void _setSelectedFilter(OfferType filter) {
    setState(() => _selectedFilter = filter);
    _fetchAndCacheShops();
  }

  @override
  Widget build(BuildContext context) {
    return _buildMapLayout(context);
  }
}
