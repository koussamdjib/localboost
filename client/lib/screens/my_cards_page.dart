import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:localboost_client/screens/deal_details_page.dart';
import 'package:localboost_client/screens/join_stamp_card_page.dart';
import 'package:localboost_client/screens/my_card_detail_page.dart';
import 'package:localboost_client/screens/search_page.dart';
import 'package:localboost_client/widgets/loyalty_card/flippable_loyalty_card.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/core/utils/distance_calculator.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';

part 'my_cards/my_cards_page_location.dart';
part 'my_cards/my_cards_page_data.dart';
part 'my_cards/my_cards_page_filters.dart';
part 'my_cards/my_cards_page_empty_state.dart';
part 'my_cards/my_cards_page_offer_card.dart';
part 'my_cards/my_cards_page_offer_header.dart';
part 'my_cards/my_cards_page_offer_sections.dart';
part 'my_cards/my_cards_page_offer_history_toggle.dart';
part 'my_cards/my_cards_page_history.dart';
part 'my_cards/my_cards_page_history_item.dart';
part 'my_cards/my_cards_page_badges.dart';

class MyCardsPage extends StatefulWidget {
  const MyCardsPage({super.key});

  @override
  State<MyCardsPage> createState() => _MyCardsPageState();
}

class _MyCardsPageState extends State<MyCardsPage> {
  String _selectedFilter = 'Tous';
  final Set<String> _expandedCards = {};
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final enrollmentProvider =
          Provider.of<EnrollmentProvider>(context, listen: false);
      if (authProvider.user != null) {
        enrollmentProvider.loadEnrollments(authProvider.user!.id);
      }
    });
  }

  void _updateSelectedFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _toggleExpandedCard(String shopId) {
    setState(() {
      if (_expandedCards.contains(shopId)) {
        _expandedCards.remove(shopId);
      } else {
        _expandedCards.add(shopId);
      }
    });
  }

  void _setCurrentPosition(LatLng position) {
    setState(() => _currentPosition = position);
  }

  @override
  void dispose() {
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
          'Mes Cartes',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Consumer<EnrollmentProvider>(
        builder: (context, enrollmentProvider, child) {
          final shops = _filteredShops;

          if (enrollmentProvider.isLoading && shops.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          return Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: shops.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primaryGreen,
                        onRefresh: () async {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          if (authProvider.user != null) {
                            await enrollmentProvider
                                .loadEnrollments(authProvider.user!.id);
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          itemCount: shops.length,
                          itemBuilder: (context, index) {
                            return _buildOfferCard(shops[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
