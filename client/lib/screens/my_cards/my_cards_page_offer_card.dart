part of '../my_cards_page.dart';

extension _MyCardsPageOfferCard on _MyCardsPageState {
  Widget _buildOfferCard(Shop shop) {
    // Enrolled loyalty cards → flippable card (front=stamps, back=QR).
    if (shop.enrollmentId != null && shop.dealType == 'Loyalty') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlippableLoyaltyCard(shop: shop),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyCardDetailPage(shop: shop),
                  ),
                ),
                icon: const Icon(Icons.open_in_new, size: 14),
                label: Text(
                  'Voir détails',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Non-enrolled loyalty discovery cards → promotional card with Join CTA.
    if (shop.dealType == 'Loyalty') {
      return _buildDiscoveryLoyaltyCard(shop);
    }

    // Marketplace / discovery cards (deals, flash sales, flyers).
    final isExpanded = _expandedCards.contains(shop.id);
    final hasHistory = shop.history != null && shop.history!.isNotEmpty;
    final isEnrolled = shop.enrollmentId != null;

    return GestureDetector(
      onTap: isEnrolled
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyCardDetailPage(shop: shop),
                ),
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(shop),
            _buildCardProgress(shop),
            _buildCardReward(shop),
            if (hasHistory) ...[
              Divider(height: 1, color: Colors.grey.shade200),
              _buildCardHistoryToggle(shop.id, isExpanded),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildStampHistory(shop.history!),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryLoyaltyCard(Shop shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: shop.logoUrl.isNotEmpty
                    ? Image.network(shop.logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _discoveryLogoFallback(shop.name))
                    : _discoveryLogoFallback(shop.name),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${shop.rewardIcon} ${shop.rewardValue}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${shop.totalRequired} timbres requis',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => JoinStampCardPage(shop: shop)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                textStyle: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
              child: const Text('Rejoindre'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _discoveryLogoFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
          color: AppColors.primaryGreen,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
