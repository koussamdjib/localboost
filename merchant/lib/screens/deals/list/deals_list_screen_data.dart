part of '../deals_list_screen.dart';

extension _DealsListScreenData on _DealsListScreenState {
  Future<void> _loadDeals() async {
    final shopProvider = context.read<ShopProvider>();
    final dealProvider = context.read<DealProvider>();
    final selectedShop = shopProvider.selectedShop;

    if (selectedShop == null) {
      dealProvider.clearDeals();
      return;
    }

    await dealProvider.loadDeals(selectedShop.id.toString());
  }
}
