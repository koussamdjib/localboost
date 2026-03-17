part of '../flyers_list_screen.dart';

extension _FlyersListScreenView on _FlyersListScreenState {
  Widget _buildFlyersListScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Circulaires'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Brouillons'),
            Tab(text: 'Publiés'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createFlyer,
            tooltip: 'Nouvelle circulaire',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<FlyerProvider, ShopProvider>(
          builder: (context, flyerProvider, shopProvider, _) {
            final selectedShop = shopProvider.selectedShop;

            if (selectedShop == null) {
              return _buildNoShopState(hasAnyShop: shopProvider.hasShop);
            }

            if (flyerProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (flyerProvider.error != null && flyerProvider.flyers.isEmpty) {
              return _buildErrorState(flyerProvider.error!);
            }

            return Column(
              children: [
                _buildSelectedShopBanner(selectedShop.name),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFlyersList(isDraft: true),
                      _buildFlyersList(isDraft: false),
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

  Widget _buildFlyersList({required bool isDraft}) {
    return Consumer<FlyerProvider>(
      builder: (context, provider, _) {
        final flyers =
            isDraft ? provider.draftFlyers : provider.publishedFlyers;

        if (flyers.isEmpty) {
          return _buildEmptyState(isDraft);
        }

        return RefreshIndicator(
          onRefresh: _loadFlyers,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: flyers.length,
            itemBuilder: (context, index) {
              return FlyerCardWidget(
                flyer: flyers[index],
                onTap: () => _viewFlyer(flyers[index]),
                onEdit: () => _editFlyer(flyers[index]),
                onDelete: () => _deleteFlyer(flyers[index]),
              );
            },
          ),
        );
      },
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

  Widget _buildEmptyState(bool isDraft) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDraft ? Icons.drafts_outlined : Icons.campaign_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isDraft ? 'Aucun brouillon' : 'Aucune circulaire publiée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDraft
                ? 'Créez votre première circulaire'
                : 'Publiez une circulaire pour la rendre visible',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoShopState({required bool hasAnyShop}) {
    final message = hasAnyShop
        ? 'Sélectionnez une boutique pour gérer les circulaires.'
        : 'Créez d\'abord une boutique avant de gérer les circulaires.';

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
              onPressed: _loadFlyers,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
