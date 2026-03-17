part of '../search_page.dart';

extension _SearchPageResults on _SearchPageState {
  Widget _buildSearchResults() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final filter = searchProvider.currentFilter;

        return FutureBuilder<List<Shop>>(
          future: _shouldLoadShops(filter)
              ? SearchService.searchShopsAsync(
                  filter: filter,
                  userLocation: _userLocation,
                )
              : Future<List<Shop>>.value(const <Shop>[]),
          builder: (context, shopsSnapshot) {
            return FutureBuilder<List<Shop>>(
              future: _shouldLoadDeals(filter)
                  ? SearchService.searchDealsAsync(
                      filter: filter,
                      userLocation: _userLocation,
                    )
                  : Future<List<Shop>>.value(const <Shop>[]),
              builder: (context, dealsSnapshot) {
                return FutureBuilder<List<Flyer>>(
                  future: filter.offerType == OfferType.flyer
                      ? SearchService.searchFlyersAsync(
                          query: filter.query,
                          category: filter.category,
                          userLocation: _userLocation,
                        )
                      : Future<List<Flyer>>.value(const <Flyer>[]),
                  builder: (context, flyersSnapshot) {
                    final shops = shopsSnapshot.data ?? const <Shop>[];
                    final deals = dealsSnapshot.data ?? const <Shop>[];
                    final flyers = flyersSnapshot.data ?? const <Flyer>[];
                    final isLoadingShops = shopsSnapshot.connectionState ==
                        ConnectionState.waiting;
                    final isLoadingDeals = dealsSnapshot.connectionState ==
                        ConnectionState.waiting;
                    final isLoadingFlyers = flyersSnapshot.connectionState ==
                        ConnectionState.waiting;

                    return Column(
                      children: [
                        if (_isLoadingLocation ||
                            isLoadingShops ||
                            isLoadingDeals ||
                            isLoadingFlyers)
                          const LinearProgressIndicator(
                            minHeight: 2,
                            color: AppColors.primaryGreen,
                          ),
                        if (filter.hasActiveFilters)
                          _buildActiveFilters(filter),
                        _buildResultsCount(
                          filter,
                          deals.length + shops.length + flyers.length,
                        ),
                        Expanded(
                          child: shops.isEmpty &&
                                  deals.isEmpty &&
                                  flyers.isEmpty
                              ? _buildNoResults()
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: deals.length +
                                      shops.length +
                                      flyers.length,
                                  itemBuilder: (context, index) {
                                    if (index < deals.length) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: DealCardWidget(
                                          shop: deals[index],
                                          onTap: _showShopDetails,
                                        ),
                                      );
                                    }

                                    if (index < deals.length + shops.length) {
                                      final shop = shops[index - deals.length];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: DealCardWidget(
                                          shop: shop,
                                          onTap: _showShopDetails,
                                        ),
                                      );
                                    }

                                    final flyer = flyers[
                                        index - deals.length - shops.length];
                                    return _buildFlyerResultCard(flyer);
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  bool _shouldLoadShops(SearchFilter filter) {
    switch (filter.offerType) {
      case OfferType.deal:
      case OfferType.flashSale:
      case OfferType.flyer:
        return false;
      case OfferType.all:
      case OfferType.loyalty:
        return true;
    }
  }

  bool _shouldLoadDeals(SearchFilter filter) {
    switch (filter.offerType) {
      case OfferType.deal:
      case OfferType.flashSale:
        return true;
      case OfferType.all:
      case OfferType.loyalty:
      case OfferType.flyer:
        return false;
    }
  }

  Widget _buildFlyerResultCard(Flyer flyer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: flyer.thumbnailUrl != null && flyer.thumbnailUrl!.isNotEmpty
              ? Image.network(
                  flyer.thumbnailUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFlyerPlaceholder(flyer),
                )
              : _buildFlyerPlaceholder(flyer),
        ),
        title: Text(
          flyer.storeName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(
              flyer.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              flyer.validUntil,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlyerPlaceholder(Flyer flyer) {
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(
        flyer.fileType == FlyerType.pdf ? Icons.picture_as_pdf : Icons.image,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildResultsCount(SearchFilter filter, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$total résultat${total > 1 ? 's' : ''}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoalText,
            ),
          ),
          Text(
            filter.sortBy.displayName,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
