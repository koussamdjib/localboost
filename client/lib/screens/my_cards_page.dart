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
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_shared/models/search_filter.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_shared/services/flyer_service.dart';
import 'package:localboost_shared/services/search_service.dart';

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
  String _selectedSort = 'Défaut';
  LatLng? _currentPosition;
  final Set<String> _expandedCards = {};
  final FlyerService _flyerService = FlyerService();

  List<Shop> _marketplaceOffers = <Shop>[];
  bool _isLoadingMarketplaceOffers = false;
  String? _marketplaceOffersError;

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final enrollmentProvider =
          Provider.of<EnrollmentProvider>(context, listen: false);
      if (authProvider.user != null) {
        enrollmentProvider.loadEnrollments(authProvider.user!.id);
      }
      _loadMarketplaceOffers();
    });
  }

  void _updateSelectedFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _updateSelectedSort(String sort) {
    setState(() {
      _selectedSort = sort;
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
    setState(() {
      _currentPosition = position;
    });
    _loadMarketplaceOffers();
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
          'Mes Offres',
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

          if ((enrollmentProvider.isLoading || _isLoadingMarketplaceOffers) &&
              shops.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          return Column(
            children: [
              _buildFilterChips(),
              _buildSortBar(),
              if (_marketplaceOffersError != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    _marketplaceOffersError!,
                    style: GoogleFonts.poppins(
                      color: Colors.orange.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Expanded(
                child: shops.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primaryGreen,
                        onRefresh: () async {
                          final prevStamps = enrollmentProvider.enrollments
                              .fold<int>(0, (sum, e) => sum + e.stampsCollected);
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          final messenger = ScaffoldMessenger.of(context);
                          await Future.wait<void>([
                            if (authProvider.user != null)
                              enrollmentProvider
                                  .loadEnrollments(authProvider.user!.id),
                            _loadMarketplaceOffers(),
                          ]);
                          final newStamps = enrollmentProvider.enrollments
                              .fold<int>(0, (sum, e) => sum + e.stampsCollected);
                          if (newStamps > prevStamps) {
                            if (!mounted) return;
                            final diff = newStamps - prevStamps;
                            messenger.showSnackBar(SnackBar(
                              content: Text(
                                '\uD83C\uDF89 +$diff timbre${diff > 1 ? "s" : ""} re\u00e7u${diff > 1 ? "s" : ""} !',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: AppColors.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 3),
                            ));
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
