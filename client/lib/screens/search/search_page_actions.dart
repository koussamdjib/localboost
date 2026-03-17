part of '../search_page.dart';

extension _SearchPageActions on _SearchPageState {
  void _onSearchChanged() {
    _setShowHistory(_searchController.text.isEmpty);
    context.read<SearchProvider>().updateQuery(_searchController.text);
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      return;
    }

    context.read<SearchProvider>().addToHistory(query);
    _searchController.text = query;
    _searchFocusNode.unfocus();
    _setShowHistory(false);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchProvider>().updateQuery('');
    _setShowHistory(true);
  }

  void _showFilterSheet() {
    FilterBottomSheet.show(context);
  }

  void _showShopDetails(Shop shop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DealDetailsPage(shop: shop),
      ),
    );
  }
}
