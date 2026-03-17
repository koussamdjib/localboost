part of '../dashboard_screen.dart';

extension _DashboardScreenData on _DashboardScreenState {
  Future<void> _loadDashboardData() async {
    _setStateSafe(() => _isLoading = true);

    final shopProvider = context.read<ShopProvider>();
    final flyerProvider = context.read<FlyerProvider>();
    final dealProvider = context.read<DealProvider>();
    final loyaltyProvider = context.read<LoyaltyProvider>();

    await shopProvider.loadMyShops();

    final selectedShop = shopProvider.selectedShop;
    if (selectedShop == null) {
      _setStateSafe(() => _isLoading = false);
      return;
    }

    final shopId = selectedShop.id.toString();

    // Load data from all providers in parallel for the selected shop.
    await Future.wait([
      flyerProvider.loadFlyers(shopId),
      dealProvider.loadDeals(shopId),
      loyaltyProvider.loadPrograms(shopId),
    ]);

    _setStateSafe(() => _isLoading = false);
  }
}
