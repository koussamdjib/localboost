part of '../deals_list_screen.dart';

extension _DealsListScreenView on _DealsListScreenState {
  Widget _buildDealsListScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Offres'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Actives'),
            Tab(text: 'Brouillons'),
            Tab(text: 'Expirées'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateDeal,
            tooltip: 'Créer une offre',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<DealProvider, ShopProvider>(
          builder: (context, dealProvider, shopProvider, _) {
            final selectedShop = shopProvider.selectedShop;

            if (selectedShop == null) {
              return _buildNoShopState(hasAnyShop: shopProvider.hasShop);
            }

            if (dealProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (dealProvider.error != null && dealProvider.deals.isEmpty) {
              return _buildErrorState(dealProvider.error!);
            }

            return Column(
              children: [
                _buildSelectedShopBanner(selectedShop.name),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDealsList(dealProvider.activeDeals, 'actives'),
                      _buildDealsList(dealProvider.draftDeals, 'brouillons'),
                      _buildDealsList(dealProvider.expiredDeals, 'expirées'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedShopBanner(String shopName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.primaryGreen.withValues(alpha: 0.06),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: 'Boutique active\n',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            TextSpan(
              text: shopName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealsList(List deals, String emptyLabel) {
    if (deals.isEmpty) {
      return _buildEmptyState('Aucune offre $emptyLabel');
    }

    return RefreshIndicator(
      onRefresh: _loadDeals,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: deals.length,
        itemBuilder: (context, index) {
          final deal = deals[index];
          return DealCardWidget(
            deal: deal,
            onTap: () => _navigateToDealDetail(deal),
            onEdit: () => _navigateToEditDeal(deal),
            onDelete: () => _confirmDelete(deal),
            onActivate: () => _activateDeal(deal.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style:
                GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateDeal,
            icon: const Icon(Icons.add),
            label: const Text('Créer une offre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoShopState({required bool hasAnyShop}) {
    final message = hasAnyShop
        ? 'Sélectionnez une boutique pour gérer les offres.'
        : 'Créez d\'abord une boutique avant de gérer les offres.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: 68, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Text(
              hasAnyShop
                  ? 'Retournez dans Mes boutiques pour en sélectionner une.'
                  : 'Retournez dans Mes boutiques pour créer votre première boutique.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadDeals,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
