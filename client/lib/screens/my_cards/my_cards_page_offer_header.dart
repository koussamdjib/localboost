part of '../my_cards_page.dart';

extension _MyCardsPageOfferHeader on _MyCardsPageState {
  Widget _buildCardHeader(Shop shop) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DealDetailsPage(shop: shop)),
        );
      },
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShopLogo(shop),
                const SizedBox(width: 16),
                Expanded(child: _buildShopInfo(shop)),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildShopLogo(Shop shop) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          shop.logoUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              shop.name[0],
              style: GoogleFonts.poppins(
                color: AppColors.primaryGreen,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopInfo(Shop shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                shop.name,
                style: GoogleFonts.poppins(
                  color: AppColors.charcoalText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (shop.isRedeemed)
              _buildStatusBadge('Utilisé', Icons.check_circle, Colors.grey)
            else if (shop.isComplete)
              _buildStatusBadge(
                'Prêt',
                Icons.celebration,
                AppColors.successGreen,
              )
            else
              _buildTypeBadge(shop.dealType),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                shop.location,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (shop.latitude != 0.0 || shop.longitude != 0.0) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.near_me_rounded,
                size: 12,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 3),
              Text(
                _formatDistance(_getDistance(shop)),
                style: GoogleFonts.poppins(
                  color: AppColors.primaryGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
