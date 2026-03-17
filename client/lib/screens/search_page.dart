import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:localboost_client/screens/deal_details_page.dart';
import 'package:localboost_client/widgets/deal_card_widget.dart';
import 'package:localboost_client/widgets/filter_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_shared/models/search_filter.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/search_provider.dart';
import 'package:localboost_shared/services/search_service.dart';

part 'search/search_page_location.dart';
part 'search/search_page_actions.dart';
part 'search/search_page_search_field.dart';
part 'search/search_page_history.dart';
part 'search/search_page_results.dart';
part 'search/search_page_results_filters.dart';
part 'search/search_page_no_results.dart';

/// Search page with results and filtering
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  LatLng? _userLocation;
  bool _isLoadingLocation = true;
  bool _showHistory = true;

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initLocation();

    final searchProvider = context.read<SearchProvider>();
    _searchController.text = searchProvider.currentFilter.query;

    if (_searchController.text.isEmpty) {
      _searchFocusNode.requestFocus();
    } else {
      _showHistory = false;
    }

    _searchController.addListener(_onSearchChanged);
  }

  void _setShowHistory(bool value) {
    setState(() {
      _showHistory = value;
    });
  }

  void _setLocationSuccess(LatLng location) {
    setState(() {
      _userLocation = location;
      _isLoadingLocation = false;
    });
  }

  void _setLocationLoadingDone() {
    setState(() {
      _isLoadingLocation = false;
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalText),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchField(),
      ),
      body: _showHistory ? _buildSearchHistory() : _buildSearchResults(),
    );
  }
}
