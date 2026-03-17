part of '../flyers_list_screen.dart';

extension _FlyersListScreenData on _FlyersListScreenState {
  Future<void> _loadFlyers() async {
    final provider = context.read<FlyerProvider>();
    final selectedShop = context.read<ShopProvider>().selectedShop;

    if (selectedShop == null) {
      provider.clear();
      return;
    }

    await provider.loadFlyers(selectedShop.id.toString());
  }
}
