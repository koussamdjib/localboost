import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_client/screens/enterprise_profile/enterprise_tab_deals.dart';
import 'package:localboost_client/screens/enterprise_profile/enterprise_tab_flyers.dart';
import 'package:localboost_client/screens/enterprise_profile/enterprise_tab_info.dart';
import 'package:localboost_client/screens/enterprise_profile/enterprise_tab_stamp_cards.dart';
import 'package:localboost_client/services/favorite_service.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_shared/models/search_filter.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/models/shop_discovery_shop.dart';
import 'package:localboost_shared/services/api/endpoints/shop_endpoints.dart';
import 'package:localboost_shared/services/flyer_service.dart';
import 'package:localboost_shared/services/search_service.dart';

/// Full enterprise detail page with 4 tabs:
///   1. Informations â€” description, contact, map
///   2. Deals â€” active deals
///   3. Cartes de FidÃ©litÃ© â€” loyalty stamp card programs
///   4. Prospectus â€” flyers / circulaires
class EnterpriseProfilePage extends StatefulWidget {
  final int shopId;

  const EnterpriseProfilePage({super.key, required this.shopId});

  @override
  State<EnterpriseProfilePage> createState() => _EnterpriseProfilePageState();
}

class _EnterpriseProfilePageState extends State<EnterpriseProfilePage>
    with SingleTickerProviderStateMixin {
  final ShopEndpoints _shopEndpoints = ShopEndpoints();

  ShopDiscoveryShop? _shop;
  List<Shop> _deals = [];
  List<Flyer> _flyers = [];
  List<Shop> _loyaltyCards = [];
  bool _isFavorite = false;
  bool _isLoading = true;
  String? _error;

  late final TabController _tabController;

  static const _tabs = [
    Tab(text: 'Infos'),
    Tab(text: 'Deals'),
    Tab(text: 'FidÃ©litÃ©'),
    Tab(text: 'Prospectus'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _load();
    FavoriteService.instance.isFavorite(widget.shopId).then((v) {
      if (mounted) setState(() => _isFavorite = v);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    final next = await FavoriteService.instance.toggle(widget.shopId);
    if (mounted) setState(() => _isFavorite = next);
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final shopResponse =
          await _shopEndpoints.getShopDetail(widget.shopId);
      final shopData = shopResponse.data;

      // Load deals and flyers in parallel, filtered server-side by shop_id.
      // Loyalty cards are derived from embedded program summaries in shop detail.
      final results = await Future.wait([
        SearchService.searchDealsAsync(
            filter: const SearchFilter(offerType: OfferType.deal),
            shopId: shopData.id),
        FlyerService().listFlyers(shopId: shopData.id),
      ]);

      final shopDeals = results[0] as List<Shop>;
      final shopFlyers = results[1] as List<Flyer>;

      // Build Shop objects from the loyalty program summaries already embedded
      // in the shop detail response â€” no extra API call needed.
      final loyaltyShops = shopData.loyaltyPrograms.map((p) => Shop(
            id: p.id.toString(),
            name: shopData.name,
            stamps: 0,
            totalRequired: p.stampsRequired,
            dealType: 'Loyalty',
            timeLeft: '',
            location: shopData.address,
            rewardValue: p.rewardLabel,
            rewardType: 'free_item',
            imageUrl: shopData.coverImageUrl,
            logoUrl: shopData.logoUrl,
            latitude: shopData.latitude ?? 0.0,
            longitude: shopData.longitude ?? 0.0,
          )).toList();

      if (mounted) {
        setState(() {
          _shop = shopData;
          _deals = shopDeals;
          _loyaltyCards = loyaltyShops;
          _flyers = shopFlyers;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: const BackButton(color: AppColors.charcoalText)),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }
    if (_error != null || _shop == null) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: const BackButton(color: AppColors.charcoalText)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _error ?? 'Commerce introuvable',
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen),
                child: const Text('RÃ©essayer',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final shop = _shop!;
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(shop, innerBoxIsScrolled),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              EnterpriseTabInfo(shop: shop),
              EnterpriseTabDeals(deals: _deals),
              EnterpriseTabStampCards(loyaltyCards: _loyaltyCards),
              EnterpriseTabFlyers(flyers: _flyers),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ShopDiscoveryShop shop, bool innerBoxIsScrolled) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 220,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: AppColors.primaryGreen,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red.shade300 : Colors.white,
          ),
          tooltip:
              _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
          onPressed: _toggleFavorite,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsets.only(left: 56, bottom: 60, right: 56),
        title: Text(
          shop.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            shadows: [
              Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4)
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: _buildCoverBackground(shop),
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: _tabs,
        labelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        isScrollable: false,
      ),
    );
  }

  Widget _buildCoverBackground(ShopDiscoveryShop shop) {
    return Stack(
      fit: StackFit.expand,
      children: [
        shop.coverImageUrl.isNotEmpty
            ? Image.network(
                shop.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _gradientBox(),
              )
            : _gradientBox(),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0x88000000)],
              stops: [0.4, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 52,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: shop.logoUrl.isNotEmpty
                      ? Image.network(shop.logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _logoFallback(shop.name))
                      : _logoFallback(shop.name),
                ),
              ),
              if (shop.category.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    shop.category,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _gradientBox() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _logoFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
            color: AppColors.primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
