import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:localboost_client/screens/flyer_detail_page.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/core/utils/distance_calculator.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_shared/services/flyer_service.dart';

part 'flyers/flyers_page_location.dart';
part 'flyers/flyers_page_data.dart';
part 'flyers/flyers_page_filters.dart';
part 'flyers/flyers_page_filter_category.dart';
part 'flyers/flyers_page_filter_chips.dart';
part 'flyers/flyers_page_empty_state.dart';
part 'flyers/flyers_page_card.dart';
part 'flyers/flyers_page_header.dart';
part 'flyers/flyers_page_header_badges.dart';
part 'flyers/flyers_page_products.dart';
part 'flyers/flyers_page_product_card.dart';
part 'flyers/flyers_page_footer.dart';

class FlyersPage extends StatefulWidget {
  const FlyersPage({super.key});

  @override
  State<FlyersPage> createState() => _FlyersPageState();
}

class _FlyersPageState extends State<FlyersPage> {
  final FlyerService _flyerService = FlyerService();

  FlyerCategory? _selectedCategory;
  FlyerType? _selectedType;
  String _selectedSort = 'Plus récent';
  LatLng? _currentPosition;
  late Future<List<Flyer>> _flyersFuture;

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _flyersFuture = _flyerService.listFlyers();
    _initLocation();
  }

  void _updateSelectedSort(String sort) {
    setState(() {
      _selectedSort = sort;
    });
  }

  void _updateSelectedCategory(FlyerCategory? category, bool selected) {
    setState(() {
      _selectedCategory = selected ? category : null;
    });
  }

  void _updateSelectedType(FlyerType? type, bool selected) {
    setState(() {
      _selectedType = selected ? type : null;
    });
  }

  void _setCurrentPosition(LatLng position) {
    setState(() {
      _currentPosition = position;
    });
  }

  void _refreshFlyers() {
    setState(() {
      _flyersFuture = _flyerService.listFlyers();
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Prospectus',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSortBar(),
          _buildCategoryFilter(),
          Expanded(
            child: FutureBuilder<List<Flyer>>(
              future: _flyersFuture,
              builder: (context, snapshot) {
                final filteredFlyers = _filteredFlyers(snapshot.data ?? const <Flyer>[]);

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }

                if (snapshot.hasError && !snapshot.hasData) {
                  return _buildLoadErrorState();
                }

                if (filteredFlyers.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshFlyers();
                    await _flyersFuture;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFlyers.length,
                    itemBuilder: (context, index) {
                      return _buildFlyerCard(filteredFlyers[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
