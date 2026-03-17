import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:localboost_client/screens/deal_details_page.dart';
import 'package:localboost_client/widgets/deal_card_widget.dart';
import 'package:localboost_client/widgets/filter_bottom_sheet.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/search_filter.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/services/search_service.dart';
import 'package:provider/provider.dart';
import 'package:localboost_shared/providers/search_provider.dart';

/// Full listing of all deals with filtering.
class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  List<Shop> _deals = [];
  bool _isLoading = false;
  String? _error;
  SearchFilter _filter = const SearchFilter(offerType: OfferType.deal);
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadDeals(); // load immediately without waiting for GPS
    _initLocation(); // resolve location in background → refresh
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) {
        setState(() =>
            _userLocation = LatLng(pos.latitude, pos.longitude));
        _loadDeals(); // refresh with GPS position
      }
    } catch (_) {}
  }

  Future<void> _loadDeals() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await SearchService.searchDealsAsync(
        filter: _filter,
        userLocation: _userLocation,
      );
      if (mounted) setState(() => _deals = results);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
    if (!mounted) return;
    final filter = context.read<SearchProvider>().currentFilter;
    setState(() => _filter = filter.copyWith(offerType: OfferType.deal));
    _loadDeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Deals',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded,
                color: AppColors.charcoalText),
            onPressed: _openFilters,
            tooltip: 'Filtrer',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _deals.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDeals,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen),
                child: const Text('Réessayer',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (_deals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Aucun deal disponible',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: _loadDeals,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _deals.length,
        itemBuilder: (context, index) {
          final shop = _deals[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DealCardWidget(
              shop: shop,
              isListItem: true,
              onTap: (s) => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DealDetailsPage(shop: s)),
              ),
            ),
          );
        },
      ),
    );
  }
}
