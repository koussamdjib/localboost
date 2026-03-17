import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:localboost_client/screens/deal_details_page.dart';
import 'package:localboost_client/screens/deals_page.dart';
import 'package:localboost_client/screens/enterprises_page.dart';
import 'package:localboost_client/screens/flyers_page.dart';
import 'package:localboost_client/screens/join_stamp_card_page.dart';
import 'package:localboost_client/screens/notifications_page.dart';
import 'package:localboost_client/screens/shop_detail_page.dart';
import 'package:localboost_client/screens/stamp_cards_page.dart';
import 'package:localboost_client/widgets/deal_card_widget.dart';
import 'package:localboost_client/widgets/home/flyer_card.dart';
import 'package:localboost_client/widgets/home/offer_carousel.dart';
import 'package:localboost_client/widgets/home/stamp_card_preview.dart';
import 'package:localboost_client/widgets/loyalty_card/flippable_loyalty_card.dart';
import 'package:localboost_client/widgets/map_view_widget.dart';
import 'package:localboost_client/widgets/search_bar_widget.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_shared/models/search_filter.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_shared/services/api_notification_service.dart';
import 'package:localboost_shared/services/flyer_service.dart';
import 'package:localboost_shared/services/search_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng _currentPosition = const LatLng(11.5721, 43.1456); // Default Djibouti
  final MapController _mapController = MapController();
  bool _isLoadingLocation = true;
  int _unreadNotifications = 0;
  int _refreshKey = 0;

  StreamSubscription<Position>? _positionStream;

  // Home page data
  List<Shop> _deals = [];
  List<Shop> _stampCards = [];
  List<Flyer> _flyers = [];
  bool _isLoadingHome = false;

  /// Minimum displacement (metres) before a position update is acted upon.
  static const double _minDistanceMetres = 20.0;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadUnreadCount();
    _loadHomeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadEnrollments();
    });
  }

  Future<void> _loadHomeData() async {
    if (!mounted) return;
    setState(() => _isLoadingHome = true);
    try {
      final results = await Future.wait([
        SearchService.searchDealsAsync(
          filter: const SearchFilter(
            offerType: OfferType.deal,
            sortBy: SortOption.nearest,
          ),
          userLocation: _currentPosition,
        ),
        SearchService.searchShopsAsync(
          filter: const SearchFilter(
            offerType: OfferType.loyalty,
            sortBy: SortOption.nearest,
          ),
          userLocation: _currentPosition,
        ),
        FlyerService().listFlyers(),
      ]);
      if (mounted) {
        setState(() {
          _deals = results[0] as List<Shop>;
          _stampCards = results[1] as List<Shop>;
          _flyers = results[2] as List<Flyer>;
        });
      }
    } catch (_) {
      // silently degrade — empty lists shown
    } finally {
      if (mounted) setState(() => _isLoadingHome = false);
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final result = await ApiNotificationService().fetchNotifications();
      if (mounted) setState(() => _unreadNotifications = result.unreadCount);
    } catch (_) {}
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _loadEnrollments() async {
    final authProvider = context.read<AuthProvider>();
    final enrollmentProvider = context.read<EnrollmentProvider>();

    if (authProvider.user != null) {
      await enrollmentProvider.loadEnrollments(authProvider.user!.id);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _refreshKey++);
    await Future.wait([_loadEnrollments(), _loadUnreadCount(), _loadHomeData()]);
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour \u2600\ufe0f';
    if (hour < 18) return 'Bon après-midi \ud83c\udf1e';
    return 'Bonsoir \ud83c\udf19';
  }

  /// Checks permissions, gets an initial fix quickly, then starts a continuous
  /// position stream so the map marker follows the user in real time.
  Future<void> _initLocation() async {
    try {
      // 1. Check that the location service is enabled on the device.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      // 2. Request permission if needed.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
          _showPermissionDialog();
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      // 3. Get a fast initial fix (last known or current).
      Position? initial;
      try {
        initial = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      if (initial != null && mounted) {
        _applyPosition(initial);
      }

      // 4. Get an accurate first fix.
      try {
        final accurate = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        if (mounted) _applyPosition(accurate);
      } catch (_) {
        // Not fatal — stream will provide updates.
      }

      // 5. Start continuous tracking.
      // AndroidSettings is Android-only; use base LocationSettings on web/Windows.
      final LocationSettings settings =
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
              ? AndroidSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: _minDistanceMetres.toInt(),
                  intervalDuration: const Duration(seconds: 5),
                  foregroundNotificationConfig: const ForegroundNotificationConfig(
                    notificationText: 'LocalBoost utilise votre position',
                    notificationTitle: 'Localisation active',
                    enableWakeLock: false,
                  ),
                )
              : LocationSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: _minDistanceMetres.toInt(),
                );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(
        (position) {
          if (mounted) _applyPosition(position);
        },
        onError: (Object error) {
          // Stream errors are non-fatal; the last known position is kept.
          if (mounted) setState(() => _isLoadingLocation = false);
        },
        cancelOnError: false,
      );
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _applyPosition(Position position) {
    final newPos = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = newPos;
      _isLoadingLocation = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mapController.move(newPos, 14);
    });
  }

  void _showPermissionDialog() {
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

  void _showShopDetails(Shop shop) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShopDetailPage(shop: shop)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('⚡', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LocalBoost',
                    style: GoogleFonts.poppins(
                      color: AppColors.charcoalText,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _timeGreeting(),
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: AppColors.charcoalText),
                if (_unreadNotifications > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.urgencyOrange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()));
              _loadUnreadCount();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchBarWidget(),
              if (_isLoadingLocation)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primaryGreen,
                ),
              _buildPromoBanner(),
              const SizedBox(height: 10),
              _buildFeaturedCard(),
              const SizedBox(height: 20),
              _buildMapSection(),
              const SizedBox(height: 24),
              if (!_isLoadingHome &&
                  _deals.isEmpty &&
                  _stampCards.isEmpty &&
                  _flyers.isEmpty)
                _buildOnboardingCTA()
              else ...[
              _buildSectionLabel('Offres Principales'),
              const SizedBox(height: 16),
              OfferCarousel(
                title: 'Deals',
                subtitle: '${_deals.length} offres disponibles',
                isLoading: _isLoadingHome,
                itemHeight: 230,
                onSeeAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DealsPage()),
                ),
                items: _deals.take(8).map((shop) {
                  return DealCardWidget(
                    shop: shop,
                    onTap: (s) => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DealDetailsPage(shop: s)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Consumer<EnrollmentProvider>(
                builder: (context, enrollmentProvider, _) {
                  final enrolledShopIds = enrollmentProvider.enrollments
                      .map((e) => e.shopId)
                      .toSet();
                  final unenrolledCards = _stampCards
                      .where((s) => !enrolledShopIds.contains(s.id))
                      .take(8)
                      .toList();
                  if (unenrolledCards.isEmpty && !_isLoadingHome) {
                    return const SizedBox.shrink();
                  }
                  return OfferCarousel(
                    title: 'Cartes de Fidélité',
                    subtitle: '${unenrolledCards.length} programmes',
                    isLoading: _isLoadingHome,
                    itemHeight: 185,
                    onSeeAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StampCardsPage()),
                    ),
                    items: unenrolledCards.map((shop) {
                      return StampCardPreview(
                        shop: shop,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => JoinStampCardPage(shop: shop)),
                        ),
                        width: 180,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              OfferCarousel(
                title: 'Prospectus',
                subtitle: '${_flyers.length} circulaires',
                isLoading: _isLoadingHome,
                itemHeight: 210,
                onSeeAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FlyersPage()),
                ),
                items: _flyers.take(8).map((flyer) {
                  return FlyerCard(flyer: flyer, width: 160);
                }).toList(),
              ),
              const SizedBox(height: 32),
              ], // end else
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingCTA() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🛍️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Découvrez les commerces\nprès de vous',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoalText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune offre n\'a été trouvée dans votre zone.\n'
            'Explorez les commerces locaux pour découvrir\n'
            'deals, prospectus et cartes de fidélité.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EnterprisesPage()),
              ),
              icon: const Icon(Icons.store_rounded, size: 18),
              label: Text(
                'Explorer les commerces',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: AppColors.charcoalText,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '⚡ Offres exclusives',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Découvrez les meilleures offres\nde votre quartier',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EnterprisesPage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Explorer les commerces →',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard() {
    // Use the first enrolled shop from the loaded stamp-cards list.
    // The search API annotates each shop with enrollmentId when the user is
    // enrolled, so this stays in sync with _loadHomeData results.
    final enrolledShop =
        _stampCards.where((s) => s.enrollmentId != null).firstOrNull;
    if (enrolledShop == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.primaryGreen, size: 16),
              const SizedBox(width: 6),
              Text(
                'Carte en cours',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FlippableLoyaltyCard(shop: enrolledShop),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Commerces à proximité',
            style: GoogleFonts.poppins(
              color: AppColors.charcoalText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        MapViewWidget(
          currentPosition: _currentPosition,
          mapController: _mapController,
          onShopTap: _showShopDetails,
        ),
      ],
    );
  }
}
