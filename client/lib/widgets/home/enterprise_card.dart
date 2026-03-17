import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_client/services/favorite_service.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop_discovery_shop.dart';

/// Card showing a brief enterprise (shop) summary.
class EnterpriseCard extends StatefulWidget {
  final ShopDiscoveryShop shop;
  final VoidCallback? onTap;

  const EnterpriseCard({super.key, required this.shop, this.onTap});

  @override
  State<EnterpriseCard> createState() => _EnterpriseCardState();
}

class _EnterpriseCardState extends State<EnterpriseCard> {
  bool _isFavorite = false;

  ShopDiscoveryShop get shop => widget.shop;

  @override
  void initState() {
    super.initState();
    FavoriteService.instance.isFavorite(shop.id).then((v) {
      if (mounted) setState(() => _isFavorite = v);
    });
  }

  Future<void> _toggleFavorite() async {
    final next = await FavoriteService.instance.toggle(shop.id);
    if (mounted) setState(() => _isFavorite = next);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCover(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(18)),
        color: Colors.grey.shade100,
        image: shop.coverImageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(shop.coverImageUrl),
                fit: BoxFit.cover,
                onError: (_, __) {},
              )
            : null,
      ),
      child: Stack(
        children: [
          // Logo overlay
          Positioned(
            bottom: -20,
            left: 14,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ClipOval(
                child: shop.logoUrl.isNotEmpty
                    ? Image.network(
                        shop.logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _logoFallback(),
                      )
                    : _logoFallback(),
              ),
            ),
          ),
          // Category badge
          if (shop.category.isNotEmpty)
            Positioned(
              top: 8,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  shop.category,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          // Favorite heart
          Positioned(
            top: 8,
            left: 10,
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.90),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey.shade400,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoFallback() {
    return Center(
      child: Text(
        shop.name.isNotEmpty ? shop.name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
          color: AppColors.primaryGreen,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shop.name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoalText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (shop.description.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              shop.description,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (shop.address.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    shop.address,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (shop.distanceKm != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.near_me_outlined,
                    size: 12, color: AppColors.primaryGreen),
                const SizedBox(width: 3),
                Text(
                  '${shop.distanceKm!.toStringAsFixed(1)} km',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _buildBadges(),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      children: [
        if (shop.hasActiveDeals)
          _badge('Offres', AppColors.urgencyOrange),
        if (shop.hasActiveDeals && shop.hasLoyaltyPrograms)
          const SizedBox(width: 6),
        if (shop.hasLoyaltyPrograms)
          _badge('Fidélité', AppColors.primaryGreen),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
