part of '../loyalty_list_screen.dart';

extension _LoyaltyListScreenData on _LoyaltyListScreenState {
  Future<void> _loadPrograms() async {
    final shopProvider = context.read<ShopProvider>();
    final loyaltyProvider = context.read<LoyaltyProvider>();
    final selectedShop = shopProvider.selectedShop;
    if (selectedShop == null) {
      loyaltyProvider.clearPrograms();
      return;
    }
    await loyaltyProvider.loadPrograms(selectedShop.id.toString());
  }
}
