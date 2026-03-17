import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_client/screens/enterprise_profile_page.dart';
import 'package:localboost_client/services/favorite_service.dart';
import 'package:localboost_client/widgets/home/enterprise_card.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop_discovery_shop.dart';
import 'package:localboost_shared/services/api/endpoints/shop_endpoints.dart';

/// Lists all registered businesses (shops / merchants).
class EnterprisesPage extends StatefulWidget {
  const EnterprisesPage({super.key});

  @override
  State<EnterprisesPage> createState() => _EnterprisesPageState();
}

class _EnterprisesPageState extends State<EnterprisesPage> {
  final ShopEndpoints _shopEndpoints = ShopEndpoints();
  final TextEditingController _search = TextEditingController();

  List<ShopDiscoveryShop> _all = [];
  List<ShopDiscoveryShop> _filtered = [];
  Set<int> _favoriteIds = {};
  bool _showFavoritesOnly = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShops();
    _loadFavorites();
    _search.addListener(_onSearchChanged);
  }

  Future<void> _loadFavorites() async {
    final ids = await FavoriteService.instance.loadFavorites();
    if (mounted) {
      setState(() => _favoriteIds = ids);
      _applyFilter();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadShops() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _shopEndpoints.listShops();
      if (mounted) {
        setState(() => _all = response.data);
        _applyFilter();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() => _applyFilter();

  void _applyFilter() {
    final q = _search.text.trim().toLowerCase();
    var list = _showFavoritesOnly
        ? _all.where((s) => _favoriteIds.contains(s.id)).toList()
        : _all.toList();
    if (q.isNotEmpty) {
      list = list.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.category.toLowerCase().contains(q) ||
            s.address.toLowerCase().contains(q);
      }).toList();
    }
    setState(() => _filtered = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Entreprises',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _search,
        decoration: InputDecoration(
          hintText: 'Rechercher un commerce…',
          hintStyle:
              GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
          suffixIcon: _search.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: Colors.grey, size: 18),
                  onPressed: () {
                    _search.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.lightGray,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                  size: 14,
                  color: _showFavoritesOnly ? Colors.white : Colors.red,
                ),
                const SizedBox(width: 4),
                Text('Favoris',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _showFavoritesOnly
                          ? Colors.white
                          : AppColors.charcoalText,
                    )),
              ],
            ),
            selected: _showFavoritesOnly,
            onSelected: (val) {
              setState(() => _showFavoritesOnly = val);
              _applyFilter();
            },
            selectedColor: Colors.red,
            backgroundColor: AppColors.lightGray,
            showCheckmark: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            side: BorderSide.none,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _all.isEmpty) {
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
                onPressed: _loadShops,
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
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Aucune entreprise trouvée',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: _loadShops,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final shop = _filtered[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EnterpriseCard(
              shop: shop,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EnterpriseProfilePage(shopId: shop.id),
                  ),
                );
                _loadFavorites();
              },
            ),
          );
        },
      ),
    );
  }
}
